using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Security.Domain.Entities;

namespace Security.Infrastructure.Persistence.Configurations;

public class UserSecurityProfileConfiguration : IEntityTypeConfiguration<UserSecurityProfile>
{
  public void Configure(EntityTypeBuilder<UserSecurityProfile> builder)
  {
    builder.HasKey(x => x.UserId);

    builder.Property(x => x.TransactionPinHash)
        .IsRequired()
        .HasMaxLength(200);

    builder.Property(x => x.CreatedAt)
        .IsRequired();

    builder.Property(x => x.UpdatedAt);

    builder.HasIndex(x => x.UserId)
        .IsUnique();

    builder.ToTable("UserSecurityProfiles");
  }
}
