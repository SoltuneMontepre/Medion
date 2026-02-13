using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Sale.Domain.Entities;
using Sale.Domain.Identifiers;
using Sale.Domain.Identifiers.Id;
using Sale.Infrastructure.Persistence.Converters;

namespace Sale.Infrastructure.Persistence.Configurations;

public class OrderItemConfiguration : IEntityTypeConfiguration<OrderItem>
{
  public void Configure(EntityTypeBuilder<OrderItem> builder)
  {
    builder.HasKey(oi => oi.Id);

    builder.Property(oi => oi.Id)
        .HasConversion(new StronglyTypedIdValueConverter<OrderItemId>());

    builder.Property(oi => oi.CreatedBy)
        .HasConversion(new NullableStronglyTypedIdValueConverter<UserId>());

    builder.Property(oi => oi.UpdatedBy)
        .HasConversion(new NullableStronglyTypedIdValueConverter<UserId>());

    builder.Property(oi => oi.DeletedBy)
        .HasConversion(new NullableStronglyTypedIdValueConverter<UserId>());

    builder.Property(oi => oi.OrderId)
        .HasConversion(new StronglyTypedIdValueConverter<OrderId>());

    builder.Property(oi => oi.ProductId)
        .HasConversion(new StronglyTypedIdValueConverter<ProductId>());

    builder.Property(oi => oi.ProductCode)
        .IsRequired()
        .HasMaxLength(50);

    builder.Property(oi => oi.ProductName)
        .IsRequired()
        .HasMaxLength(200);

    builder.Property(oi => oi.Quantity)
        .IsRequired();
  }
}
