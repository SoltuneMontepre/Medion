using System.Security.Claims;
using System.Text.Json;
using Grpc.Core;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Sale.Application.Common.Attributes;
using Sale.Application.Common.Context;
using Security.API.Grpc;
using TransactionContext = Sale.Application.Common.Context.TransactionContext;

namespace Sale.API.Behaviors;

/// <summary>
///     MediatR Pipeline Behavior that intercepts commands requiring digital signature.
///
///     CLEAN ARCHITECTURE DESIGN:
///     1. This behavior sits at the layer boundary (HTTP concerns)
///     2. Reads HttpContext to extract password (infrastructure concern)
///     3. Calls gRPC to validate and sign
///     4. Stores signature in Application-level TransactionContext (scoped)
///     5. Handler injects TransactionContext - NOT HttpContext
///
///     Result: Application → Domain dependency only. Handler is pure application logic.
/// </summary>
public class TransactionSigningBehavior<TRequest, TResponse>(
    IHttpContextAccessor httpContextAccessor,
    SignatureService.SignatureServiceClient grpcClient,
    TransactionContext transactionContext,
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
                  ?? httpContext.User.FindFirst("sid")
                  ?? httpContext.User.FindFirst(ClaimTypes.NameIdentifier)
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

            // ✅ CLEAN ARCHITECTURE: Store signature in Application-level scoped context
            // Handler will inject TransactionContext to retrieve it - NOT HttpContext
            transactionContext.SignatureHash = grpcResponse.SignatureHash;
            transactionContext.TimestampUtc = grpcResponse.TimestampUtc;
            transactionContext.OperationType = operationType;
            transactionContext.UserId = userId;

            logger.LogInformation(
                "Signature stored in TransactionContext. Ready for handler to consume.");

            // Continue to next handler - signature is available via scoped context
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

