using Identity.Domain.Entities;
using Identity.Domain.Identifiers;
using Identity.Infrastructure.Persistence.Converters;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Identity.Infrastructure.Persistence.Configurations;

public class UserRoleConfiguration : IEntityTypeConfiguration<UserRole>
{
  public void Configure(EntityTypeBuilder<UserRole> builder)
  {
    builder.HasKey(e => e.Id);

    builder.Property(e => e.Id)
      .HasConversion(new StronglyTypedIdValueConverter<IdentityId>());

    builder.Property(e => e.UserId)
      .HasConversion(new StronglyTypedIdValueConverter<IdentityId>());

    builder.Property(e => e.RoleId)
      .HasConversion(new StronglyTypedIdValueConverter<IdentityId>());

    builder.Property(e => e.CreatedBy)
      .HasConversion(new NullableStronglyTypedIdValueConverter<IdentityId>());

    builder.Property(e => e.UpdatedBy)
      .HasConversion(new NullableStronglyTypedIdValueConverter<IdentityId>());

    builder.Property(e => e.DeletedBy)
      .HasConversion(new NullableStronglyTypedIdValueConverter<IdentityId>());

    builder.HasIndex(e => new { e.UserId, e.RoleId }).IsUnique();
    builder.HasIndex(e => e.IsDeleted);
  }
}
