using Identity.Domain.Entities;
using Identity.Domain.Identifiers;
using Identity.Infrastructure.Persistence.Converters;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Identity.Infrastructure.Persistence.Configurations;

public class RoleClaimConfiguration : IEntityTypeConfiguration<RoleClaim>
{
  public void Configure(EntityTypeBuilder<RoleClaim> builder)
  {
    builder.HasKey(e => e.Id);

    builder.Property(e => e.Id)
      .HasConversion(new StronglyTypedIdValueConverter<IdentityId>());

    builder.Property(e => e.RoleId)
      .HasConversion(new StronglyTypedIdValueConverter<IdentityId>());

    builder.Property(e => e.CreatedBy)
      .HasConversion(new NullableStronglyTypedIdValueConverter<IdentityId>());

    builder.Property(e => e.UpdatedBy)
      .HasConversion(new NullableStronglyTypedIdValueConverter<IdentityId>());

    builder.Property(e => e.DeletedBy)
      .HasConversion(new NullableStronglyTypedIdValueConverter<IdentityId>());

    builder.Property(e => e.ClaimType)
        .IsRequired()
        .HasMaxLength(256);

    builder.Property(e => e.ClaimValue)
        .IsRequired()
        .HasMaxLength(1024);

    builder.HasIndex(e => new { e.RoleId, e.ClaimType });
    builder.HasIndex(e => e.IsDeleted);
  }
}
