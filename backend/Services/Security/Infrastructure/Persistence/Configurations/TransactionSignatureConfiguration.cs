using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Security.Domain.Entities;
using Security.Domain.Identifiers;
using Security.Domain.ValueObjects;

namespace Security.Infrastructure.Persistence.Configurations;

public class TransactionSignatureConfiguration : IEntityTypeConfiguration<TransactionSignature>
{
    public void Configure(EntityTypeBuilder<TransactionSignature> builder)
    {
        builder.ToTable("TransactionSignatures");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasConversion(
                id => id.Value,
                value => new SignatureId(value))
            .ValueGeneratedNever();

        builder.Property(x => x.Payload)
            .IsRequired()
            .HasMaxLength(10000);

        builder.Property(x => x.OperationType)
            .IsRequired()
            .HasMaxLength(100);

        // SignatureHash is stored as string "hash:timestamp"
        builder.Property(x => x.SignatureHash)
            .HasConversion(
                hash => hash.ToString(),
                value => SignatureHash.Parse(value))
            .IsRequired()
            .HasMaxLength(500);

        builder.Property(x => x.CreatedAt)
            .IsRequired();

        builder.Property(x => x.IsDeleted)
            .HasDefaultValue(false);

        builder.HasIndex(x => x.CreatedAt);
        builder.HasIndex(x => x.OperationType);
        builder.HasIndex(x => x.CreatedBy);

        // Soft delete filter
        builder.HasQueryFilter(x => !x.IsDeleted);
    }
}
