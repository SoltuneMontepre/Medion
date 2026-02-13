using Microsoft.EntityFrameworkCore;
using Sale.Domain.Entities;
using Sale.Domain.Identifiers;
using Sale.Domain.Repositories;
using Sale.Infrastructure.Data;

namespace Sale.Infrastructure.Persistence.Repositories;

/// <summary>
///     Repository implementation for Customer entity
/// </summary>
public class CustomerRepository(SaleDbContext dbContext) : ICustomerRepository
{
    public async Task<Customer?> GetByIdAsync(CustomerId id, CancellationToken cancellationToken = default)
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

    public async Task DeleteAsync(CustomerId id, CancellationToken cancellationToken = default)
    {
        var customer = await GetByIdAsync(id, cancellationToken);
        if (customer != null)
        {
            customer.IsDeleted = true;
            customer.DeletedAt = DateTime.UtcNow;
            await UpdateAsync(customer, cancellationToken);
        }
    }

    public async Task<bool> ExistsAsync(CustomerId id, CancellationToken cancellationToken = default)
    {
        return await dbContext.Customers.AnyAsync(c => c.Id == id && !c.IsDeleted, cancellationToken);
    }

    public async Task<string> GenerateCustomerCodeAsync(CancellationToken cancellationToken = default)
    {
        var currentYear = DateTime.UtcNow.Year;
        var prefix = $"CUS-{currentYear}-";

        var lastCustomer = await dbContext.Customers
            .Where(c => c.Code.StartsWith(prefix))
            .OrderByDescending(c => c.Code)
            .FirstOrDefaultAsync(cancellationToken);

        var nextNumber = 1;
        if (lastCustomer != null)
        {
            var lastNumberPart = lastCustomer.Code[prefix.Length..];
            if (int.TryParse(lastNumberPart, out var lastNumber))
            {
                nextNumber = lastNumber + 1;
            }
        }

        return $"{prefix}{nextNumber:D6}";
    }

    public async Task<IEnumerable<Customer>> SearchAsync(string term, int limit, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(term))
            return Array.Empty<Customer>();

        var normalized = term.Trim();

        return await dbContext.Customers
            .Where(c => !c.IsDeleted &&
                        (EF.Functions.ILike(c.Code, $"%{normalized}%") ||
                         EF.Functions.ILike(c.FirstName, $"%{normalized}%") ||
                         EF.Functions.ILike(c.LastName, $"%{normalized}%") ||
                         EF.Functions.ILike(c.PhoneNumber, $"%{normalized}%")))
            .OrderBy(c => c.Code)
            .Take(limit)
            .ToListAsync(cancellationToken);
    }
}
