using Microsoft.EntityFrameworkCore;
using Sale.Domain.Entities;

namespace Sale.Infrastructure.Data;

public sealed class SaleDbContext(DbContextOptions<SaleDbContext> options) : DbContext(options)
{
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();
    public DbSet<UserDigitalSignature> UserDigitalSignatures => Set<UserDigitalSignature>();
    public DbSet<CustomerSignature> CustomerSignatures => Set<CustomerSignature>();
    public DbSet<OrderDailySequence> OrderDailySequences => Set<OrderDailySequence>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Apply all configurations from the assembly
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(SaleDbContext).Assembly);
    }
}
