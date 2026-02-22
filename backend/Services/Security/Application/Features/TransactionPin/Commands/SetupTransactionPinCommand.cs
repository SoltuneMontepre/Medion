using Security.Application.Abstractions;
using Security.Domain.Entities;

namespace Security.Application.Features.TransactionPin.Commands;

public record SetupTransactionPinCommand(Guid UserId, string PlainPin) : IRequest;

public class SetupTransactionPinCommandHandler(
    IUserSecurityProfileRepository repository,
    ILogger<SetupTransactionPinCommandHandler> logger)
    : IRequestHandler<SetupTransactionPinCommand>
{
    public async Task Handle(SetupTransactionPinCommand request, CancellationToken cancellationToken)
    {
        if (request.UserId == Guid.Empty)
            throw new ArgumentException("UserId is required.");

        if (string.IsNullOrWhiteSpace(request.PlainPin))
            throw new ArgumentException("PlainPin is required.");

        var pinHash = BCrypt.Net.BCrypt.EnhancedHashPassword(request.PlainPin);

        var profile = new UserSecurityProfile
        {
            UserId = request.UserId,
            TransactionPinHash = pinHash
        };

        await repository.AddOrUpdateAsync(profile, cancellationToken);

        logger.LogInformation("Transaction PIN setup completed for user {UserId}", request.UserId);
    }
}
