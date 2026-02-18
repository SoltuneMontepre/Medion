using Grpc.Core;
using MediatR;
using Microsoft.Extensions.Logging;
using Security.API.Grpc;
using Security.Application.Common.Abstractions;
using Security.Application.Features.Signature.Commands;

namespace Security.API.Services;

/// <summary>
///     gRPC service for transaction signature operations
///     Enables synchronous verification and signing for other services
/// </summary>
public class SignatureGrpcService(
    IMediator mediator,
    IVaultService vaultService,
    ILogger<SignatureGrpcService> logger)
    : global::Security.API.Grpc.SignatureService.SignatureServiceBase
{
    public override async Task<SignResponse> SignTransaction(
        SignRequest request,
        ServerCallContext context)
    {
        try
        {
            logger.LogInformation(
                "Received signature request for operation {OperationType} from user {UserId}",
                request.OperationType,
                request.UserId);

            // Step 1: Validate transaction password against Vault
            var isPasswordValid = await vaultService.ValidateTransactionPasswordAsync(
                request.UserId,
                request.TransactionPassword,
                context.CancellationToken);

            if (!isPasswordValid)
            {
                logger.LogWarning("Transaction password validation failed for user {UserId}", request.UserId);
                return new SignResponse
                {
                    Success = false,
                    ErrorMessage = "Transaction password validation failed"
                };
            }

            // Step 2: Generate digital signature via Vault
            var signatureHash = await vaultService.GenerateSignatureAsync(
                request.Payload,
                request.UserId,
                context.CancellationToken);

            // Step 3: Persist signature record (audit trail)
            var command = new CreateSignatureCommand(
                request.Payload,
                signatureHash,
                request.OperationType,
                Guid.Parse(request.UserId));

            await mediator.Send(command, context.CancellationToken);

            logger.LogInformation(
                "Successfully signed transaction for operation {OperationType}",
                request.OperationType);

            return new SignResponse
            {
                Success = true,
                SignatureHash = signatureHash,
                TimestampUtc = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()
            };
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error signing transaction");
            return new SignResponse
            {
                Success = false,
                ErrorMessage = ex.Message
            };
        }
    }

    public override async Task<VerifyResponse> VerifySignature(
        VerifyRequest request,
        ServerCallContext context)
    {
        try
        {
            // TODO: Implement signature verification logic
            // This would validate that the signature matches the payload
            logger.LogInformation("Verifying signature");

            await Task.CompletedTask;
            return new VerifyResponse { IsValid = true };
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error verifying signature");
            return new VerifyResponse
            {
                IsValid = false,
                ErrorMessage = ex.Message
            };
        }
    }
}

        if (string.IsNullOrWhiteSpace(request.Pin))
            throw new RpcException(new Status(StatusCode.InvalidArgument, "PIN is required."));

        var isValid = await signatureService.CheckPinAsync(userId, request.Pin, context.CancellationToken);
        return new PinResponse { IsValid = isValid };
    }

    private static bool TryParseUserId(string value, out UserId userId)
{
    userId = UserId.Empty;
    if (string.IsNullOrWhiteSpace(value))
        return false;

    if (!Guid.TryParse(value, out var guid))
        return false;

    userId = new UserId(guid);
    return true;
}
}
