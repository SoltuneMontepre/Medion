using Microsoft.EntityFrameworkCore;
using Sale.Domain.Entities;
using Sale.Domain.Identifiers.Id;
using Sale.Domain.Repositories;
using Sale.Infrastructure.Data;

namespace Sale.Infrastructure.Persistence.Repositories;

public class ProductRepository(SaleDbContext dbContext) : IProductRepository
{
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
}
