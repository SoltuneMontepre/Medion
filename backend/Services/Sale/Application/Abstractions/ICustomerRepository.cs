using Sale.Domain.Entities;
using Sale.Domain.Identifiers;

namespace Sale.Application.Abstractions;

public interface ICustomerRepository : IBaseRepository<Customer, CustomerId>
{
  Task<IEnumerable<Customer>> GetAllAsync(CancellationToken cancellationToken = default);
  Task<IEnumerable<Customer>> GetAllActiveAsync(CancellationToken cancellationToken = default);
  Task DeleteAsync(CustomerId id, CancellationToken cancellationToken = default);
  Task<bool> ExistsAsync(CustomerId id, CancellationToken cancellationToken = default);
  Task<string> GenerateCustomerCodeAsync(CancellationToken cancellationToken = default);
  Task<IEnumerable<Customer>> SearchAsync(string term, int limit, CancellationToken cancellationToken = default);
}
