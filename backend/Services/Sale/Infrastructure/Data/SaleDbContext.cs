using Microsoft.EntityFrameworkCore;
using Sale.Domain.Entities;

namespace Sale.Infrastructure.Data;

public sealed class SaleDbContext(DbContextOptions<SaleDbContext> options) : DbContext(options)
{
    public DbSet<Order> Orders => Set<Order>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        var order = modelBuilder.Entity<Order>();
        order.HasKey(o => o.Id);
        order.Property(o => o.CustomerId).IsRequired();
        order.Property(o => o.Status).IsRequired();
        order.OwnsMany(o => o.Items, b =>
        {
            b.WithOwner();
            b.Property(i => i.Sku).IsRequired();
        });
    }
}
