using Identity.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Identity.Infrastructure.Persistence.Configurations;

public class UserClaimConfiguration : IEntityTypeConfiguration<UserClaim>
{
  public void Configure(EntityTypeBuilder<UserClaim> builder)
  {
    builder.HasKey(e => e.Id);

    builder.Property(e => e.ClaimType)
        .IsRequired()
        .HasMaxLength(256);

    builder.Property(e => e.ClaimValue)
        .IsRequired()
        .HasMaxLength(1024);

    builder.HasIndex(e => new { e.UserId, e.ClaimType });
    builder.HasIndex(e => e.IsDeleted);
  }
}
