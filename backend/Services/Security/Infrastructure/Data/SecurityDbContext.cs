using Microsoft.EntityFrameworkCore;
using Sale.Domain.Entities;

namespace Security.Infrastructure.Data;

public sealed class SecurityDbContext(DbContextOptions<SecurityDbContext> options) : DbContext(options)
{
  public DbSet<UserDigitalSignature> UserDigitalSignatures => Set<UserDigitalSignature>();

  protected override void OnModelCreating(ModelBuilder modelBuilder)
  {
    modelBuilder.ApplyConfigurationsFromAssembly(typeof(SecurityDbContext).Assembly);
  }
}
