using MediatR;
using Microsoft.Extensions.Logging;
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

public class CreateSignatureCommandHandler : IRequestHandler<CreateSignatureCommand, SignatureId>
{
    private readonly ILogger<CreateSignatureCommandHandler> _logger;
    private readonly ISignatureRepository _repository;

    public CreateSignatureCommandHandler(
        ISignatureRepository repository,
        ILogger<CreateSignatureCommandHandler> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    public async Task<SignatureId> Handle(
        CreateSignatureCommand request,
        CancellationToken cancellationToken)
    {
        var signature = TransactionSignature.CreateSigned(
            request.Payload,
            request.SignatureHash,
            request.OperationType,
            request.UserId);

        await _repository.AddAsync(signature, cancellationToken);

        _logger.LogInformation("Signature record persisted for operation {OperationType}", request.OperationType);

        return signature.Id;
    }
}

public interface ISignatureRepository
{
    Task AddAsync(TransactionSignature signature, CancellationToken cancellationToken);
}
