using Identity.Domain.Abstractions;
using Identity.Domain.Entities;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Identity.Infrastructure.Persistence;

/// <summary>
///     Entity Framework DbContext for Identity Service
///     Manages all entities and their relationships
/// </summary>
public class IdentityDbContext(DbContextOptions<IdentityDbContext> options) : IdentityDbContext<User, Role, Guid>(options)
{
  public new DbSet<UserRole> UserRoles { get; set; } = null!;
    public new DbSet<UserClaim> UserClaims { get; set; } = null!;
    public new DbSet<RoleClaim> RoleClaims { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // User configuration
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Email).IsRequired().HasMaxLength(256);
            entity.Property(e => e.NormalizedEmail).IsRequired().HasMaxLength(256);
            entity.Property(e => e.UserName).IsRequired().HasMaxLength(256);
            entity.Property(e => e.NormalizedUserName).IsRequired().HasMaxLength(256);
            entity.Property(e => e.PasswordHash).IsRequired();
            entity.Property(e => e.FirstName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.LastName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.PhoneNumber).HasMaxLength(20);
            entity.Property(e => e.Department).HasMaxLength(100);
            entity.Property(e => e.ProfilePictureUrl).HasMaxLength(512);

            // Indexes for performance
            entity.HasIndex(e => e.Email).IsUnique();
            entity.HasIndex(e => e.NormalizedEmail).IsUnique();
            entity.HasIndex(e => e.UserName).IsUnique();
            entity.HasIndex(e => e.NormalizedUserName).IsUnique();
            entity.HasIndex(e => e.IsDeleted);
            entity.HasIndex(e => e.IsActive);

            // Navigation properties
            entity.HasMany(e => e.Roles)
                .WithOne(ur => ur.User)
                .HasForeignKey(ur => ur.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasMany(e => e.Claims)
                .WithOne(uc => uc.User)
                .HasForeignKey(uc => uc.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Role configuration
        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(256);
            entity.Property(e => e.NormalizedName).IsRequired().HasMaxLength(256);
            entity.Property(e => e.Description).HasMaxLength(500);

            // Indexes
            entity.HasIndex(e => e.Name).IsUnique();
            entity.HasIndex(e => e.NormalizedName).IsUnique();
            entity.HasIndex(e => e.IsDeleted);

            // Navigation properties
            entity.HasMany(e => e.UserRoles)
                .WithOne(ur => ur.Role)
                .HasForeignKey(ur => ur.RoleId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasMany(e => e.Claims)
                .WithOne(rc => rc.Role)
                .HasForeignKey(rc => rc.RoleId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // UserRole configuration (Join table)
        modelBuilder.Entity<UserRole>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => new { e.UserId, e.RoleId }).IsUnique();
            entity.HasIndex(e => e.IsDeleted);
        });

        // UserClaim configuration
        modelBuilder.Entity<UserClaim>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.ClaimType).IsRequired().HasMaxLength(256);
            entity.Property(e => e.ClaimValue).IsRequired().HasMaxLength(1024);
            entity.HasIndex(e => new { e.UserId, e.ClaimType });
            entity.HasIndex(e => e.IsDeleted);
        });

        // RoleClaim configuration
        modelBuilder.Entity<RoleClaim>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.ClaimType).IsRequired().HasMaxLength(256);
            entity.Property(e => e.ClaimValue).IsRequired().HasMaxLength(1024);
            entity.HasIndex(e => new { e.RoleId, e.ClaimType });
            entity.HasIndex(e => e.IsDeleted);
        });
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
            if (entry.State == EntityState.Added)
                entry.Entity.CreatedAt = DateTime.UtcNow;
            else if (entry.State == EntityState.Modified) entry.Entity.UpdatedAt = DateTime.UtcNow;

        return await base.SaveChangesAsync(cancellationToken);
    }
}
