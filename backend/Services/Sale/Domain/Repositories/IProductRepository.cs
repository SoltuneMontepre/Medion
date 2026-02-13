using Sale.Domain.Entities;
using Sale.Domain.Identifiers.Id;

namespace Sale.Domain.Repositories;

public interface IProductRepository
{
  Task<IReadOnlyList<Product>> GetByIdsAsync(IReadOnlyCollection<ProductId> ids, CancellationToken cancellationToken = default);
  Task<IReadOnlyList<Product>> SearchAsync(string term, int limit, CancellationToken cancellationToken = default);
}
