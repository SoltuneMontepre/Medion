using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Sale.Domain.Entities;
using Sale.Domain.Identifiers;
using Sale.Domain.Identifiers.Id;
using Sale.Infrastructure.Persistence.Converters;

namespace Sale.Infrastructure.Persistence.Configurations;

public class ProductConfiguration : IEntityTypeConfiguration<Product>
{
  public void Configure(EntityTypeBuilder<Product> builder)
  {
    builder.HasKey(p => p.Id);

    builder.Property(p => p.Id)
        .HasConversion(new StronglyTypedIdValueConverter<ProductId>());

    builder.Property(p => p.CreatedBy)
        .HasConversion(new NullableStronglyTypedIdValueConverter<UserId>());

    builder.Property(p => p.UpdatedBy)
        .HasConversion(new NullableStronglyTypedIdValueConverter<UserId>());

    builder.Property(p => p.DeletedBy)
        .HasConversion(new NullableStronglyTypedIdValueConverter<UserId>());

    builder.Property(p => p.Code)
        .IsRequired()
        .HasMaxLength(50);

    builder.HasIndex(p => p.Code)
        .IsUnique();

    builder.Property(p => p.Name)
        .IsRequired()
        .HasMaxLength(200);

    builder.Property(p => p.Specification)
        .HasMaxLength(500);

    builder.Property(p => p.Type)
        .HasMaxLength(100);

    builder.Property(p => p.Packaging)
        .HasMaxLength(100);
  }
}
