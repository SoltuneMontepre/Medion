using Audit.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Audit.Infrastructure.Data;

/// <summary>
///     Entity Framework Core database context for the Audit Service.
///     Manages the GlobalAuditLog entities and their persistence.
/// </summary>
public sealed class AuditDbContext(DbContextOptions<AuditDbContext> options) : DbContext(options)
{
  /// <summary>
  ///     The GlobalAuditLogs table containing all audit log entries.
  /// </summary>
  public DbSet<GlobalAuditLog> GlobalAuditLogs => Set<GlobalAuditLog>();

  protected override void OnModelCreating(ModelBuilder modelBuilder)
  {
    // Apply all configurations from the assembly
    modelBuilder.ApplyConfigurationsFromAssembly(typeof(AuditDbContext).Assembly);
  }
}
