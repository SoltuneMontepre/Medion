using Sale.Domain.Entities;
using Sale.Domain.Identifiers.Id;

namespace Sale.Domain.Repositories;

public interface IProductRepository
{
  Task<Product?> GetByIdAsync(ProductId id, CancellationToken cancellationToken = default);
  Task<IReadOnlyList<Product>> GetAllAsync(CancellationToken cancellationToken = default);
  Task<IReadOnlyList<Product>> GetByIdsAsync(IReadOnlyCollection<ProductId> ids, CancellationToken cancellationToken = default);
  Task<IReadOnlyList<Product>> SearchAsync(string term, int limit, CancellationToken cancellationToken = default);
  Task AddAsync(Product product, CancellationToken cancellationToken = default);
  Task UpdateAsync(Product product, CancellationToken cancellationToken = default);
  Task<bool> DeleteAsync(ProductId id, CancellationToken cancellationToken = default);
  Task<bool> ExistsByCodeAsync(string code, ProductId? excludeId = null, CancellationToken cancellationToken = default);
}
