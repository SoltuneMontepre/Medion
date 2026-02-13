using Microsoft.EntityFrameworkCore;
using Sale.Domain.Entities;
using Sale.Domain.Identifiers.Id;
using Sale.Domain.Repositories;
using Sale.Infrastructure.Data;

namespace Sale.Infrastructure.Persistence.Repositories;

public class ProductRepository(SaleDbContext dbContext) : IProductRepository
{
    public async Task<Product?> GetByIdAsync(ProductId id, CancellationToken cancellationToken = default)
    {
        return await dbContext.Products
          .FirstOrDefaultAsync(p => p.Id == id && !p.IsDeleted, cancellationToken);
    }

    public async Task<IReadOnlyList<Product>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await dbContext.Products
          .Where(p => !p.IsDeleted)
          .OrderBy(p => p.Code)
          .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Product>> GetByIdsAsync(IReadOnlyCollection<ProductId> ids,
      CancellationToken cancellationToken = default)
    {
        if (ids.Count == 0)
            return Array.Empty<Product>();

        return await dbContext.Products
          .Where(p => ids.Contains(p.Id) && !p.IsDeleted)
          .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Product>> SearchAsync(string term, int limit,
      CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(term))
            return Array.Empty<Product>();

        var normalized = term.Trim();

        return await dbContext.Products
          .Where(p => !p.IsDeleted &&
                (EF.Functions.ILike(p.Code, $"%{normalized}%") ||
                 EF.Functions.ILike(p.Name, $"%{normalized}%")))
          .OrderBy(p => p.Code)
          .Take(limit)
          .ToListAsync(cancellationToken);
    }

    public async Task AddAsync(Product product, CancellationToken cancellationToken = default)
    {
        await dbContext.Products.AddAsync(product, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(Product product, CancellationToken cancellationToken = default)
    {
        product.UpdatedAt = DateTime.UtcNow;
        dbContext.Products.Update(product);
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<bool> DeleteAsync(ProductId id, CancellationToken cancellationToken = default)
    {
        var product = await GetByIdAsync(id, cancellationToken);
        if (product == null)
            return false;

        product.IsDeleted = true;
        product.DeletedAt = DateTime.UtcNow;
        await UpdateAsync(product, cancellationToken);
        return true;
    }

    public async Task<bool> ExistsByCodeAsync(string code, ProductId? excludeId = null,
      CancellationToken cancellationToken = default)
    {
        var query = dbContext.Products
          .Where(p => !p.IsDeleted && p.Code == code);

        if (excludeId.HasValue)
            query = query.Where(p => p.Id != excludeId.Value);

        return await query.AnyAsync(cancellationToken);
    }
}
