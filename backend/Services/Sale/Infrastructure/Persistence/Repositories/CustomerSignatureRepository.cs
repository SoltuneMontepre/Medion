using Microsoft.EntityFrameworkCore;
using Sale.Application.Abstractions;
using Sale.Domain.Entities;
using Sale.Domain.Identifiers;
using Sale.Domain.Identifiers.Id;

namespace Sale.Infrastructure.Persistence.Repositories;

/// <summary>
///     Repository implementation for CustomerSignature entity.
///     Handles persistence and retrieval of digital signatures associated with customer creation operations.
///     All queries exclude soft-deleted records by default.
/// </summary>
public class CustomerSignatureRepository(SaleDbContext dbContext)
    : BaseRepository<CustomerSignature, CustomerSignatureId>(dbContext), ICustomerSignatureRepository
{
    public async Task<CustomerSignature?> GetByCustomerIdAsync(
        CustomerId customerId,
        CancellationToken cancellationToken = default)
    {
        return await Queryable
            .FirstOrDefaultAsync(cs => cs.CustomerId == customerId, cancellationToken);
    }

    public async Task<IEnumerable<CustomerSignature>> GetByUserIdAsync(
        UserId userId,
        CancellationToken cancellationToken = default)
    {
        return await Queryable
            .Where(cs => cs.SignedByUserId == userId)
            .OrderByDescending(cs => cs.SignedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<IEnumerable<CustomerSignature>> GetByDateRangeAsync(
        DateTime startDate,
        DateTime endDate,
        CancellationToken cancellationToken = default)
    {
        return await Queryable
            .Where(cs => cs.SignedAt >= startDate && cs.SignedAt <= endDate)
            .OrderByDescending(cs => cs.SignedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task MarkAsVerifiedAsync(
        CustomerSignatureId id,
        CancellationToken cancellationToken = default)
    {
        var signature = await GetByIdAsync(id, cancellationToken);
        if (signature != null)
        {
            signature.IsVerified = true;
            signature.VerifiedAt = DateTime.UtcNow;
            await UpdateAsync(signature, cancellationToken);
        }
    }
}
