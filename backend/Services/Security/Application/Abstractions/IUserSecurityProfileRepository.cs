using Security.Domain.Entities;

namespace Security.Application.Abstractions;

public interface IUserSecurityProfileRepository
{
  Task<UserSecurityProfile?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
  Task AddOrUpdateAsync(UserSecurityProfile profile, CancellationToken cancellationToken = default);
}
