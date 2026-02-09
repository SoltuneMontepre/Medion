using Identity.Domain.Entities;
using Identity.Domain.Identifiers;
using Identity.Infrastructure.Persistence.Converters;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Identity.Infrastructure.Persistence.Configurations;

public class RoleConfiguration : IEntityTypeConfiguration<Role>
{
  public void Configure(EntityTypeBuilder<Role> builder)
  {
    builder.HasKey(e => e.Id);

    builder.Property(e => e.Id)
        .HasConversion(new StronglyTypedIdValueConverter<IdentityId>());

    builder.Property(e => e.CreatedBy)
        .HasConversion(new NullableStronglyTypedIdValueConverter<IdentityId>());

    builder.Property(e => e.UpdatedBy)
        .HasConversion(new NullableStronglyTypedIdValueConverter<IdentityId>());

    builder.Property(e => e.DeletedBy)
        .HasConversion(new NullableStronglyTypedIdValueConverter<IdentityId>());

    builder.Property(e => e.Name)
        .IsRequired()
        .HasMaxLength(256);

    builder.Property(e => e.NormalizedName)
        .IsRequired()
        .HasMaxLength(256);

    builder.Property(e => e.Description)
        .HasMaxLength(500);

    // Indexes
    builder.HasIndex(e => e.Name).IsUnique();
    builder.HasIndex(e => e.NormalizedName).IsUnique();
    builder.HasIndex(e => e.IsDeleted);

    // Navigation properties
    builder.HasMany(e => e.UserRoles)
        .WithOne(ur => ur.Role)
        .HasForeignKey(ur => ur.RoleId)
        .OnDelete(DeleteBehavior.Cascade);

    builder.HasMany(e => e.Claims)
        .WithOne(rc => rc.Role)
        .HasForeignKey(rc => rc.RoleId)
        .OnDelete(DeleteBehavior.Cascade);
  }
}
