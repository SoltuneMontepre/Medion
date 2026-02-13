using Sale.Domain.Entities;
using Sale.Domain.Identifiers;

namespace Sale.Domain.Repositories;

public interface IUserDigitalSignatureRepository
{
  Task<UserDigitalSignature?> GetByUserIdAsync(UserId userId, CancellationToken cancellationToken = default);
  Task AddOrUpdateAsync(UserDigitalSignature signature, CancellationToken cancellationToken = default);
}
