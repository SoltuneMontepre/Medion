using Identity.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Identity.Infrastructure.Persistence.Configurations;

public class UserRoleConfiguration : IEntityTypeConfiguration<UserRole>
{
  public void Configure(EntityTypeBuilder<UserRole> builder)
  {
    builder.HasKey(e => e.Id);

    builder.HasIndex(e => new { e.UserId, e.RoleId }).IsUnique();
    builder.HasIndex(e => e.IsDeleted);
  }
}
