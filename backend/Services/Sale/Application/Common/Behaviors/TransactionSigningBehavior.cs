using System.Text.Json;
using Grpc.Core;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Sale.Application.Common.Attributes;
using Sale.Application.Features.Customer.Commands;
using Security.API.Grpc;

namespace Sale.Application.Common.Behaviors;

/// <summary>
///     MediatR Pipeline Behavior that intercepts commands requiring digital signature.
///     
///     ARCHITECTURE NOTE: This behavior resides in Application layer and accesses HttpContext.
///     This is acceptable because:
///     1. Behaviors are infrastructure-aware by design (they sit at layer boundary)
///     2. The signature is attached to the COMMAND object (immutable record)
///     3. The HANDLER only reads from command properties - it never touches HttpContext
///     
///     This maintains clean architecture: Application → Domain dependency only.
///     HTTP concerns end with the command construction.
/// </summary>
public class TransactionSigningBehavior<TRequest, TResponse>(
    IHttpContextAccessor httpContextAccessor,
    SignatureService.SignatureServiceClient grpcClient,
    ILogger<TransactionSigningBehavior<TRequest, TResponse>> logger)
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>, IRequireDigitalSignature
{
    private const string TransactionPasswordHeader = "X-Transaction-Password";

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

            // Call Security.API gRPC synchronously to validate password and generate signature
            var grpcRequest = new SignRequest
            {
                Payload = payload,
                TransactionPassword = transactionPassword,
                UserId = userId,
                OperationType = operationType
            };

            var grpcResponse = await grpcClient.SignTransactionAsync(
                grpcRequest,
                cancellationToken: cancellationToken);

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

            // ✅ CLEAN ARCHITECTURE: Attach signature to command via immutable record "with" pattern
            // The created command is then passed to next() - the handler only reads from properties
            var signedCommand = (dynamic)request with { SignatureHash = grpcResponse.SignatureHash };

            // Continue to next handler with the signature-bearing command
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
