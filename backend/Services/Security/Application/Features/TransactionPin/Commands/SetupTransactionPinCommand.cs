using BCrypt.Net;
using MediatR;
using Microsoft.Extensions.Logging;
using Security.Application.Abstractions;
using Security.Domain.Entities;

namespace Security.Application.Features.TransactionPin.Commands;

public record SetupTransactionPinCommand(Guid UserId, string PlainPin) : IRequest;

public class SetupTransactionPinCommandHandler : IRequestHandler<SetupTransactionPinCommand>
{
  private readonly IUserSecurityProfileRepository _repository;
  private readonly ILogger<SetupTransactionPinCommandHandler> _logger;

  public SetupTransactionPinCommandHandler(
      IUserSecurityProfileRepository repository,
      ILogger<SetupTransactionPinCommandHandler> logger)
  {
    _repository = repository;
    _logger = logger;
  }

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

    await _repository.AddOrUpdateAsync(profile, cancellationToken);

    _logger.LogInformation("Transaction PIN setup completed for user {UserId}", request.UserId);
  }
}
