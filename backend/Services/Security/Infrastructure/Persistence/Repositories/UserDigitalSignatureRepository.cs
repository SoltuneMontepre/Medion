using Microsoft.EntityFrameworkCore;
using Sale.Domain.Entities;
using Sale.Domain.Identifiers;
using Security.Application.Abstractions;
using Security.Infrastructure.Data;

namespace Security.Infrastructure.Persistence.Repositories;

public class UserDigitalSignatureRepository(SecurityDbContext dbContext) : IUserDigitalSignatureRepository
{
    public async Task<UserDigitalSignature?> GetByUserIdAsync(UserId userId, CancellationToken cancellationToken = default)
    {
        return await dbContext.UserDigitalSignatures
            .FirstOrDefaultAsync(x => x.UserId == userId, cancellationToken);
    }

    public async Task AddOrUpdateAsync(UserDigitalSignature signature, CancellationToken cancellationToken = default)
    {
        var existing = await GetByUserIdAsync(signature.UserId, cancellationToken);
        if (existing == null)
        {
            signature.CreatedAt = DateTime.UtcNow;
            await dbContext.UserDigitalSignatures.AddAsync(signature, cancellationToken);
        }
        else
        {
            existing.PinHash = signature.PinHash;
            existing.PinSalt = signature.PinSalt;
            existing.PublicKey = signature.PublicKey;
            existing.UpdatedAt = DateTime.UtcNow;
        }

        await dbContext.SaveChangesAsync(cancellationToken);
    }
}
