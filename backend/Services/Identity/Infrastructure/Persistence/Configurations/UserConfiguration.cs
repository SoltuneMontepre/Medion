using Identity.Domain.Entities;
using Identity.Domain.Identifiers;
using Identity.Infrastructure.Persistence.Converters;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Identity.Infrastructure.Persistence.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
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

        builder.Property(e => e.Email)
            .IsRequired()
            .HasMaxLength(256);

        builder.Property(e => e.NormalizedEmail)
            .IsRequired()
            .HasMaxLength(256);

        builder.Property(e => e.UserName)
            .IsRequired()
            .HasMaxLength(256);

        builder.Property(e => e.NormalizedUserName)
            .IsRequired()
            .HasMaxLength(256);

        builder.Property(e => e.PasswordHash)
            .IsRequired();

        builder.Property(e => e.FirstName)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(e => e.LastName)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(e => e.PhoneNumber)
            .HasMaxLength(20);

        builder.Property(e => e.Department)
            .HasMaxLength(100);

        builder.Property(e => e.ProfilePictureUrl)
            .HasMaxLength(512);

        // Indexes for performance
        builder.HasIndex(e => e.Email).IsUnique();
        builder.HasIndex(e => e.NormalizedEmail).IsUnique();
        builder.HasIndex(e => e.UserName).IsUnique();
        builder.HasIndex(e => e.NormalizedUserName).IsUnique();
        builder.HasIndex(e => e.IsDeleted);
        builder.HasIndex(e => e.IsActive);

        // Navigation properties
        builder.HasMany(e => e.Roles)
            .WithOne(ur => ur.User)
            .HasForeignKey(ur => ur.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(e => e.Claims)
            .WithOne(uc => uc.User)
            .HasForeignKey(uc => uc.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
