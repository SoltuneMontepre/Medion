using Identity.Domain.Abstractions;
using Identity.Domain.Entities;
using Identity.Domain.Identifiers;

namespace Identity.Infrastructure.Persistence;

/// <summary>
///     Entity Framework DbContext for Identity Service
///     Manages all entities and their relationships
/// </summary>
public class IdentityDbContext(DbContextOptions<IdentityDbContext> options)
    : IdentityDbContext<User, Role, IdentityId>(options)
{
    public new DbSet<UserRole> UserRoles { get; set; } = null!;
    public new DbSet<UserClaim> UserClaims { get; set; } = null!;
    public new DbSet<RoleClaim> RoleClaims { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Apply all configurations from the assembly
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(IdentityDbContext).Assembly);
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        // Configure audit trail interceptor if needed
        base.OnConfiguring(optionsBuilder);
    }

    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        // Set audit timestamps before saving
        var entries = ChangeTracker.Entries<IAuditable>();
        foreach (var entry in entries)
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.CreatedAt = DateTime.UtcNow;
                    break;
                case EntityState.Modified:
                    entry.Entity.UpdatedAt = DateTime.UtcNow;
                    break;
                case EntityState.Detached:
                case EntityState.Unchanged:
                case EntityState.Deleted:
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

        return await base.SaveChangesAsync(cancellationToken);
    }
}
