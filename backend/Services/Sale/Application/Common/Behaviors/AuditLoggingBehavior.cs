using System.Text.Json;
using MassTransit;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Sale.Application.Common.DTOs;
using Sale.Application.Events;

namespace Sale.Application.Common.Behaviors;

/// <summary>
///     MediatR Pipeline Behavior that publishes audit events to RabbitMQ asynchronously
///     Runs AFTER the main handler completes successfully
/// </summary>
public class AuditLoggingBehavior<TRequest, TResponse>(
    IPublishEndpoint publishEndpoint,
    IHttpContextAccessor httpContextAccessor,
    ILogger<AuditLoggingBehavior<TRequest, TResponse>> logger)
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
  public async Task<TResponse> Handle(
      TRequest request,
      RequestHandlerDelegate<TResponse> next,
      CancellationToken cancellationToken)
  {
    var httpContext = httpContextAccessor.HttpContext;
    var startTime = DateTime.UtcNow;

    try
    {
      // Execute the actual handler
      var response = await next();

      // Publish audit event asynchronously (fire-and-forget)
      _ = PublishAuditEventAsync(request, response, startTime, httpContext, cancellationToken);

      return response;
    }
    catch (Exception ex)
    {
      logger.LogError(ex, "Error in request handler for {RequestType}", typeof(TRequest).Name);

      // Publish audit event for failed operations too
      _ = PublishAuditEventAsync(request, null, startTime, httpContext, cancellationToken, ex);

      throw;
    }
  }

  private async Task PublishAuditEventAsync(
      TRequest request,
      TResponse? response,
      DateTime startTime,
      HttpContext? httpContext,
      CancellationToken cancellationToken,
      Exception? exception = null)
  {
    try
    {
      var userIdClaim = httpContext?.User.FindFirst("sub")
                        ?? httpContext?.User.FindFirst("NameIdentifier");
      var userId = userIdClaim?.Value ?? "SYSTEM";

      var ipAddress = httpContext?.Connection.RemoteIpAddress?.ToString() ?? "UNKNOWN";

      // Extract transaction signature if available
      var signature = httpContext?.Items.TryGetValue("TransactionSignature", out var sig) == true
          ? (TransactionSignatureDto?)sig
          : null;

      // Determine action and entity info from request type
      var (action, entityType, entityId) = ExtractActionMetadata(request);

      var payload = JsonSerializer.Serialize(request, new JsonSerializerOptions
      {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
      });

      var auditEvent = new AuditLogIntegrationEvent
      {
        UserId = userId,
        Action = action,
        EntityType = entityType,
        EntityId = entityId,
        Payload = payload,
        SignatureHash = signature?.SignatureHash,
        IpAddress = ipAddress,
        StatusCode = exception != null ? 500 : 200,
        ErrorMessage = exception?.Message
      };

      logger.LogInformation(
          "Publishing audit event for action {Action} on entity {EntityType} {EntityId}",
          action,
          entityType,
          entityId);

      await publishEndpoint.Publish(auditEvent, cancellationToken);

      logger.LogInformation(
          "Audit event published (took {Elapsed}ms)",
          (DateTime.UtcNow - startTime).TotalMilliseconds);
    }
    catch (Exception ex)
    {
      // Log but don't throw - audit failures should not impact business logic
      logger.LogError(ex, "Failed to publish audit event for {RequestType}", typeof(TRequest).Name);
    }
  }

  private (string Action, string EntityType, string EntityId) ExtractActionMetadata(TRequest request)
  {
    // Convention-based extraction: CommandName format = "Create|Update|Delete{EntityType}Command"
    var typeName = typeof(TRequest).Name;

    return typeName switch
    {
      var s when s.StartsWith("Create") => ("CREATE", ExtractEntityType(s, "Create"), "NEW"),
      var s when s.StartsWith("Update") => ("UPDATE", ExtractEntityType(s, "Update"), ExtractIdFromRequest()),
      var s when s.StartsWith("Delete") => ("DELETE", ExtractEntityType(s, "Delete"), ExtractIdFromRequest()),
      _ => ("EXECUTE", typeof(TRequest).Name, "N/A")
    };

    string ExtractEntityType(string name, string prefix) =>
        name.Replace(prefix, "").Replace("Command", "").ToUpperInvariant();

    string ExtractIdFromRequest()
    {
      // Try to extract ID from common property names
      var idProperty = typeof(TRequest).GetProperty("Id")
                       ?? typeof(TRequest).GetProperty("CustomerId")
                       ?? typeof(TRequest).GetProperty("EntityId");

      return idProperty?.GetValue(request)?.ToString() ?? "UNKNOWN";
    }
  }
}
