using Microsoft.EntityFrameworkCore;
using Sale.Domain.Entities;

namespace Sale.Infrastructure.Data;

public sealed class SaleDbContext(DbContextOptions<SaleDbContext> options) : DbContext(options)
{
    public DbSet<Customer> Customers => Set<Customer>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Apply all configurations from the assembly
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(SaleDbContext).Assembly);
    }
}
