using MassTransit;
using Microsoft.EntityFrameworkCore;
using Sale.Domain.Entities;

namespace Sale.Infrastructure.Data;

/// <summary>
///     Sale Service DbContext with MassTransit Outbox pattern for atomic event persistence.
///
///     ATOMICITY GUARANTEE:
///     - Customer entity and AuditLogIntegrationEvent saved in SAME database transaction
///     - MassTransit Outbox automatically publishes events to RabbitMQ
///     - If service crashes, event remains in outbox until successfully published
///     - Result: Exactly-once delivery semantics, no event loss
/// </summary>
public sealed class SaleDbContext(DbContextOptions<SaleDbContext> options) : DbContext(options)
{
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();
    public DbSet<UserDigitalSignature> UserDigitalSignatures => Set<UserDigitalSignature>();
    public DbSet<OrderDailySequence> OrderDailySequences => Set<OrderDailySequence>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Apply all configurations from the assembly
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(SaleDbContext).Assembly);

        // ✅ Configure MassTransit Outbox for atomic event persistence
        // OutboxState table: Tracks published events
        // InboxState table: Prevents duplicate processing of same event (idempotency)
        modelBuilder.AddInboxStateEntity();
        modelBuilder.AddOutboxStateEntity();
        modelBuilder.AddOutboxMessageEntity();
    }
}
