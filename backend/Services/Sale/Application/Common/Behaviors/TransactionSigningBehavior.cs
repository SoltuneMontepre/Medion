using System.Text;
using System.Text.Json;
using Grpc.Core;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Sale.Application.Common.Attributes;
using Sale.Application.Common.DTOs;
using Security.API.Grpc;

namespace Sale.Application.Common.Behaviors;

/// <summary>
///     MediatR Pipeline Behavior that intercepts commands requiring digital signature.
///     Calls Security.API gRPC service to validate password and generate signature.
///     Attaches signature to context for downstream handlers.
/// </summary>
public class TransactionSigningBehavior<TRequest, TResponse>(
    IHttpContextAccessor httpContextAccessor,
    SignatureService.SignatureServiceClient grpcClient,
    ILogger<TransactionSigningBehavior<TRequest, TResponse>> logger)
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>, IRequireDigitalSignature
{
  private const string TransactionPasswordHeader = "X-Transaction-Password";
  private const string SignatureContextKey = "TransactionSignature";

  public async Task<TResponse> Handle(
      TRequest request,
      RequestHandlerDelegate<TResponse> next,
      CancellationToken cancellationToken)
  {
    var httpContext = httpContextAccessor.HttpContext
                      ?? throw new InvalidOperationException("HttpContext is required for transaction signing");

    // Extract transaction password from header
    if (!httpContext.Request.Headers.TryGetValue(TransactionPasswordHeader, out var passwordValues))
    {
      logger.LogWarning("Transaction password header not provided");
      throw new UnauthorizedAccessException(
          $"Sensitive operation requires '{TransactionPasswordHeader}' header");
    }

    var transactionPassword = passwordValues.FirstOrDefault();
    if (string.IsNullOrWhiteSpace(transactionPassword))
    {
      throw new UnauthorizedAccessException("Transaction password cannot be empty");
    }

    // Extract user ID from claims
    var userIdClaim = httpContext.User.FindFirst("sub")
                      ?? httpContext.User.FindFirst("NameIdentifier")
                      ?? throw new UnauthorizedAccessException("User ID claim not found");

    var userId = userIdClaim.Value;

    // Serialize the request payload for signing
    var payload = JsonSerializer.Serialize(request, new JsonSerializerOptions
    {
      PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    });

    var operationType = request.GetType().Name;

    try
    {
      logger.LogInformation(
          "Initiating transaction signing for operation {Operation} by user {UserId}",
          operationType,
          userId);

      // Call Security.API gRPC synchronously
      var grpcRequest = new SignRequest
      {
        Payload = payload,
        TransactionPassword = transactionPassword,
        UserId = userId,
        OperationType = operationType
      };

      var grpcResponse = await grpcClient.SignTransactionAsync(grpcRequest, cancellationToken: cancellationToken);

      if (!grpcResponse.Success)
      {
        logger.LogWarning(
            "Transaction signing failed: {ErrorMessage}",
            grpcResponse.ErrorMessage);
        throw new UnauthorizedAccessException(
            $"Transaction validation failed: {grpcResponse.ErrorMessage}");
      }

      logger.LogInformation(
          "Transaction successfully signed. Signature hash: {Hash}",
          grpcResponse.SignatureHash[..16] + "...");

      // Attach signature to HttpContext for downstream handlers
      var signatureDto = new TransactionSignatureDto
      {
        SignatureHash = grpcResponse.SignatureHash,
        TimestampUtc = grpcResponse.TimestampUtc,
        OperationType = operationType,
        UserId = userId
      };

      httpContext.Items[SignatureContextKey] = signatureDto;

      // Continue to next handler
      return await next();
    }
    catch (RpcException rpcEx)
    {
      logger.LogError(
          rpcEx,
          "gRPC error during transaction signing. Status: {Status}",
          rpcEx.Status);
      throw new InvalidOperationException(
          $"Security service unavailable: {rpcEx.Status.Detail}",
          rpcEx);
    }
  }
}
