using System.Text.Json;
using MassTransit;
using MediatR;
using Medion.Shared.Events;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Sale.Application.Common.Context;
using TransactionContext = Sale.Application.Common.Context.TransactionContext;

namespace Sale.Application.Common.Behaviors;

/// <summary>
///     MediatR Pipeline Behavior that publishes audit events to RabbitMQ asynchronously
///     Runs AFTER the main handler completes successfully.
///
///     CLEAN ARCHITECTURE:
///     - This behavior runs at API boundary (has access to HttpContext)
///     - Extracts user info and signature from TransactionContext (scoped, Application layer)
///     - Publishes audit event via MassTransit Outbox pattern
///     - Ensures signature is captured for non-repudiation
/// </summary>
public class AuditLoggingBehavior<TRequest, TResponse>(
    IPublishEndpoint publishEndpoint,
    IHttpContextAccessor httpContextAccessor,
    Sale.Application.Common.Context.TransactionContext transactionContext,
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

        var response = await next();

        await PublishAuditEventAsync(request, response, startTime, httpContext, cancellationToken);

        return response;
    }

    private async Task PublishAuditEventAsync(
        TRequest request,
        TResponse? response,
        DateTime startTime,
        HttpContext? httpContext,
        CancellationToken cancellationToken)
    {
        try
        {
            var userIdClaim = httpContext?.User.FindFirst("sub")
                              ?? httpContext?.User.FindFirst("NameIdentifier");
            var userId = userIdClaim?.Value ?? "SYSTEM";

            var ipAddress = httpContext?.Connection.RemoteIpAddress?.ToString() ?? "UNKNOWN";

            // ✅ CLEAN ARCHITECTURE: Get signature from scoped TransactionContext (not HttpContext)
            var signatureHash = transactionContext.SignatureHash;

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
                SignatureHash = signatureHash,
                IpAddress = ipAddress,
                StatusCode = 200,
                ErrorMessage = null
            };

            logger.LogInformation(
                "Publishing audit event for action {Action} on entity {EntityType} {EntityId} (signature: {Signature})",
                action,
                entityType,
                entityId,
                signatureHash?[..16] + "...");

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
