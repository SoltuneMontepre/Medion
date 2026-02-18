using Microsoft.EntityFrameworkCore;
using Sale.Domain.Entities;
using Security.Domain.Entities;

namespace Security.Infrastructure.Data;

public sealed class SecurityDbContext(DbContextOptions<SecurityDbContext> options) : DbContext(options)
{
    public DbSet<UserDigitalSignature> UserDigitalSignatures => Set<UserDigitalSignature>();
    public DbSet<TransactionSignature> TransactionSignatures => Set<TransactionSignature>();
    public DbSet<UserSecurityProfile> UserSecurityProfiles => Set<UserSecurityProfile>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(SecurityDbContext).Assembly);
    }
}
