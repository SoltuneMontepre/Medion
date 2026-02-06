using Sale.Domain.Entities;

namespace Sale.Domain.Repositories;

/// <summary>
///     Repository interface for Customer entity
/// </summary>
public interface ICustomerRepository
{
  Task<Customer?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
  Task<IEnumerable<Customer>> GetAllAsync(CancellationToken cancellationToken = default);
  Task<IEnumerable<Customer>> GetAllActiveAsync(CancellationToken cancellationToken = default);
  Task AddAsync(Customer customer, CancellationToken cancellationToken = default);
  Task UpdateAsync(Customer customer, CancellationToken cancellationToken = default);
  Task DeleteAsync(Guid id, CancellationToken cancellationToken = default);
  Task<bool> ExistsAsync(Guid id, CancellationToken cancellationToken = default);
}
