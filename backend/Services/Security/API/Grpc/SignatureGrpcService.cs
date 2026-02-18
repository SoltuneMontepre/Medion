using Grpc.Core;
using MediatR;
using Security.Application.Abstractions;
using Security.Application.Common.Abstractions;
using Security.Application.Features.Signature.Commands;

namespace Security.API.Grpc;

/// <summary>
///     gRPC service for transaction signature operations
///     Enables synchronous verification and signing for other services
/// </summary>
public class SignatureGrpcService(
    IMediator mediator,
    IVaultService vaultService,
    IUserSecurityProfileRepository userSecurityProfileRepository,
    ILogger<SignatureGrpcService> logger)
    : SignatureService.SignatureServiceBase
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

            if (!Guid.TryParse(request.UserId, out var userId))
                throw new RpcException(new Status(StatusCode.InvalidArgument, "User ID is invalid"));

            // Step 1: Validate transaction PIN against stored BCrypt hash
            var profile = await userSecurityProfileRepository.GetByUserIdAsync(userId, context.CancellationToken);
            if (profile == null ||
                !BCrypt.Net.BCrypt.EnhancedVerify(request.TransactionPassword, profile.TransactionPinHash))
            {
                logger.LogWarning("Transaction PIN validation failed for user {UserId}", request.UserId);
                throw new RpcException(new Status(StatusCode.Unauthenticated, "Mã PIN giao dịch không chính xác"));
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
                userId);

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
