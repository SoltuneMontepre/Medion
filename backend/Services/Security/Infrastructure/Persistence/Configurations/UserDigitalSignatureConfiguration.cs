using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Sale.Domain.Entities;
using Sale.Domain.Identifiers;
using Security.Infrastructure.Persistence.Converters;

namespace Security.Infrastructure.Persistence.Configurations;

public class UserDigitalSignatureConfiguration : IEntityTypeConfiguration<UserDigitalSignature>
{
    public void Configure(EntityTypeBuilder<UserDigitalSignature> builder)
    {
        builder.HasKey(x => x.UserId);

        builder.Property(x => x.UserId)
            .HasConversion(new StronglyTypedIdValueConverter<UserId>());

        builder.Property(x => x.PinHash)
            .IsRequired()
            .HasColumnType("bytea");

        builder.Property(x => x.PinSalt)
            .IsRequired()
            .HasColumnType("bytea");

        builder.Property(x => x.PublicKey)
            .IsRequired()
            .HasMaxLength(500);
    }
}
