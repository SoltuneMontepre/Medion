using Microsoft.EntityFrameworkCore;
using Sale.Application.Abstractions;
using Sale.Domain.Entities;
using Sale.Domain.Identifiers;

namespace Sale.Infrastructure.Persistence.Repositories;

public class UserDigitalSignatureRepository(SaleDbContext dbContext) : IUserDigitalSignatureRepository
{
    public async Task<UserDigitalSignature?> GetByUserIdAsync(UserId userId,
        CancellationToken cancellationToken = default)
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
