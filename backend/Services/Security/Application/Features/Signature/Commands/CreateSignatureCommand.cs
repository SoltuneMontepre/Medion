using Security.Domain.Entities;
using Security.Domain.Identifiers;

namespace Security.Application.Features.Signature.Commands;

/// <summary>
///     Command to persist a signature record for audit trail
/// </summary>
public record CreateSignatureCommand(
    string Payload,
    string SignatureHash,
    string OperationType,
    Guid UserId) : IRequest<SignatureId>;

public class CreateSignatureCommandHandler(
    ISignatureRepository repository,
    ILogger<CreateSignatureCommandHandler> logger)
    : IRequestHandler<CreateSignatureCommand, SignatureId>
{
    public async Task<SignatureId> Handle(
        CreateSignatureCommand request,
        CancellationToken cancellationToken)
    {
        var signature = TransactionSignature.CreateSigned(
            request.Payload,
            request.SignatureHash,
            request.OperationType,
            request.UserId);

        await repository.AddAsync(signature, cancellationToken);

        logger.LogInformation("Signature record persisted for operation {OperationType}", request.OperationType);

        return signature.Id;
    }
}

public interface ISignatureRepository
{
    Task AddAsync(TransactionSignature signature, CancellationToken cancellationToken);
}
