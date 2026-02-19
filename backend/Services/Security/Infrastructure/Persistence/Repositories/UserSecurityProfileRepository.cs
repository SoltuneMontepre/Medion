using Microsoft.EntityFrameworkCore;
using Security.Application.Abstractions;
using Security.Domain.Entities;
using Security.Infrastructure.Data;

namespace Security.Infrastructure.Persistence.Repositories;

public class UserSecurityProfileRepository(SecurityDbContext dbContext) : IUserSecurityProfileRepository
{
  public async Task<UserSecurityProfile?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
  {
    return await dbContext.UserSecurityProfiles
        .FirstOrDefaultAsync(x => x.UserId == userId, cancellationToken);
  }

  public async Task AddOrUpdateAsync(UserSecurityProfile profile, CancellationToken cancellationToken = default)
  {
    var existing = await GetByUserIdAsync(profile.UserId, cancellationToken);
    if (existing == null)
    {
      profile.CreatedAt = DateTime.UtcNow;
      await dbContext.UserSecurityProfiles.AddAsync(profile, cancellationToken);
    }
    else
    {
      existing.TransactionPinHash = profile.TransactionPinHash;
      existing.UpdatedAt = DateTime.UtcNow;
    }

    await dbContext.SaveChangesAsync(cancellationToken);
  }
}
