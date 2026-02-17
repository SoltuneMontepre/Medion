using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Sale.Domain.Entities;
using Sale.Domain.Identifiers;
using Sale.Infrastructure.Persistence.Converters;

namespace Sale.Infrastructure.Persistence.Configurations;

/// <summary>
///     Entity Framework Core configuration for the CustomerSignature entity.
///     Defines the database schema, relationships, and constraints for customer digital signatures.
/// </summary>
public class CustomerSignatureConfiguration : IEntityTypeConfiguration<CustomerSignature>
{
  public void Configure(EntityTypeBuilder<CustomerSignature> builder)
  {
    // Primary key
    builder.HasKey(cs => cs.Id);

    // Property conversions for strongly-typed IDs
    builder.Property(cs => cs.Id)
        .HasConversion(new StronglyTypedIdValueConverter<CustomerSignatureId>());

    builder.Property(cs => cs.CustomerId)
        .HasConversion(new StronglyTypedIdValueConverter<CustomerId>());

    builder.Property(cs => cs.SignedByUserId)
        .HasConversion(new StronglyTypedIdValueConverter<UserId>());

    builder.Property(cs => cs.CreatedBy)
        .HasConversion(new NullableStronglyTypedIdValueConverter<UserId>());

    builder.Property(cs => cs.UpdatedBy)
        .HasConversion(new NullableStronglyTypedIdValueConverter<UserId>());

    builder.Property(cs => cs.DeletedBy)
        .HasConversion(new NullableStronglyTypedIdValueConverter<UserId>());

    // Signature property - stores Vault signature
    builder.Property(cs => cs.Signature)
        .IsRequired()
        .HasColumnType("text");

    // Signed payload - stores base64-encoded payload for audit and verification
    builder.Property(cs => cs.SignedPayload)
        .IsRequired()
        .HasColumnType("text");

    // Timestamps
    builder.Property(cs => cs.SignedAt)
        .IsRequired()
        .HasColumnType("timestamp with time zone");

    builder.Property(cs => cs.VerifiedAt)
        .HasColumnType("timestamp with time zone");

    // Verification flag
    builder.Property(cs => cs.IsVerified)
        .IsRequired()
        .HasDefaultValue(false);

    // Foreign key relationships
    builder.HasOne(cs => cs.Customer)
        .WithMany()
        .HasForeignKey(cs => cs.CustomerId)
        .OnDelete(DeleteBehavior.Cascade)
        .IsRequired();

    // Indexes for efficient querying
    builder.HasIndex(cs => cs.CustomerId)
        .IsUnique()
        .HasDatabaseName("IX_CustomerSignature_CustomerId");

    builder.HasIndex(cs => cs.SignedByUserId)
        .HasDatabaseName("IX_CustomerSignature_SignedByUserId");

    builder.HasIndex(cs => cs.SignedAt)
        .HasDatabaseName("IX_CustomerSignature_SignedAt");

    builder.HasIndex(cs => cs.IsVerified)
        .HasDatabaseName("IX_CustomerSignature_IsVerified");

    // Table name
    builder.ToTable("CustomerSignatures");
  }
}
