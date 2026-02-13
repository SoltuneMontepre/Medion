using Microsoft.EntityFrameworkCore;
using Sale.Application.Abstractions;
using Sale.Domain.Entities;
using Sale.Domain.Identifiers.Id;
using Sale.Infrastructure.Data;
using Sale.Infrastructure.Persistence;

namespace Sale.Infrastructure.Persistence.Repositories;

public class ProductRepository(SaleDbContext dbContext) : BaseRepository<Product, ProductId>(dbContext),
  IProductRepository
{
    public async Task<IReadOnlyList<Product>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await Queryable
            .OrderBy(p => p.Code)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Product>> GetByIdsAsync(IReadOnlyCollection<ProductId> ids,
      CancellationToken cancellationToken = default)
    {
        if (ids.Count == 0)
            return Array.Empty<Product>();

        return await Queryable
            .Where(p => ids.Contains(p.Id))
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Product>> SearchAsync(string term, int limit,
      CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(term))
            return Array.Empty<Product>();

        var normalized = term.Trim();

        return await Queryable
        .Where(p => EF.Functions.ILike(p.Code, $"%{normalized}%") ||
            EF.Functions.ILike(p.Name, $"%{normalized}%"))
        .OrderBy(p => p.Code)
        .Take(limit)
        .ToListAsync(cancellationToken);
    }

    public async Task<bool> DeleteAsync(ProductId id, CancellationToken cancellationToken = default)
    {
        var product = await GetByIdAsync(id, cancellationToken);
        if (product == null)
            return false;
        await DeleteAsync(product, cancellationToken);
        return true;
    }

    public async Task<bool> ExistsByCodeAsync(string code, ProductId? excludeId = null,
      CancellationToken cancellationToken = default)
    {
        var query = Queryable
            .Where(p => p.Code == code);

        if (excludeId.HasValue)
            query = query.Where(p => p.Id != excludeId.Value);

        return await query.AnyAsync(cancellationToken);
    }
}
