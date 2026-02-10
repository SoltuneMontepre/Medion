using Sale.Domain.Entities;
using Sale.Domain.Identifiers;

namespace Sale.Domain.Repositories;

/// <summary>
///     Repository interface for Customer entity
/// </summary>
public interface ICustomerRepository
{
    Task<Customer?> GetByIdAsync(CustomerId id, CancellationToken cancellationToken = default);
    Task<IEnumerable<Customer>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<Customer>> GetAllActiveAsync(CancellationToken cancellationToken = default);
    Task AddAsync(Customer customer, CancellationToken cancellationToken = default);
    Task UpdateAsync(Customer customer, CancellationToken cancellationToken = default);
    Task DeleteAsync(CustomerId id, CancellationToken cancellationToken = default);
    Task<bool> ExistsAsync(CustomerId id, CancellationToken cancellationToken = default);
    Task<string> GenerateCustomerCodeAsync(CancellationToken cancellationToken = default);
}
