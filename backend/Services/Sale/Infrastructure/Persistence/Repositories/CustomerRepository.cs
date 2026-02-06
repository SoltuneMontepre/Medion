using Microsoft.EntityFrameworkCore;
using Sale.Domain.Entities;
using Sale.Domain.Repositories;
using Sale.Infrastructure.Data;

namespace Sale.Infrastructure.Persistence.Repositories;

/// <summary>
///     Repository implementation for Customer entity
/// </summary>
public class CustomerRepository(SaleDbContext dbContext) : ICustomerRepository
{
  public async Task<Customer?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
  {
    return await dbContext.Customers
        .FirstOrDefaultAsync(c => c.Id == id && !c.IsDeleted, cancellationToken);
  }

  public async Task<IEnumerable<Customer>> GetAllAsync(CancellationToken cancellationToken = default)
  {
    return await dbContext.Customers
        .Where(c => !c.IsDeleted)
        .OrderBy(c => c.LastName)
        .ThenBy(c => c.FirstName)
        .ToListAsync(cancellationToken);
  }

  public async Task<IEnumerable<Customer>> GetAllActiveAsync(CancellationToken cancellationToken = default)
  {
    return await dbContext.Customers
        .Where(c => !c.IsDeleted)
        .OrderBy(c => c.LastName)
        .ThenBy(c => c.FirstName)
        .ToListAsync(cancellationToken);
  }

  public async Task AddAsync(Customer customer, CancellationToken cancellationToken = default)
  {
    await dbContext.Customers.AddAsync(customer, cancellationToken);
    await dbContext.SaveChangesAsync(cancellationToken);
  }

  public async Task UpdateAsync(Customer customer, CancellationToken cancellationToken = default)
  {
    customer.UpdatedAt = DateTime.UtcNow;
    dbContext.Customers.Update(customer);
    await dbContext.SaveChangesAsync(cancellationToken);
  }

  public async Task DeleteAsync(Guid id, CancellationToken cancellationToken = default)
  {
    var customer = await GetByIdAsync(id, cancellationToken);
    if (customer != null)
    {
      customer.IsDeleted = true;
      customer.DeletedAt = DateTime.UtcNow;
      await UpdateAsync(customer, cancellationToken);
    }
  }

  public async Task<bool> ExistsAsync(Guid id, CancellationToken cancellationToken = default)
  {
    return await dbContext.Customers.AnyAsync(c => c.Id == id && !c.IsDeleted, cancellationToken);
  }
}
