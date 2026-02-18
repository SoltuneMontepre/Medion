using Sale.Domain.Entities;
using Sale.Domain.Identifiers;

namespace Security.Application.Abstractions;

public interface IUserDigitalSignatureRepository
{
    Task<UserDigitalSignature?> GetByUserIdAsync(UserId userId, CancellationToken cancellationToken = default);
    Task AddOrUpdateAsync(UserDigitalSignature signature, CancellationToken cancellationToken = default);
}
