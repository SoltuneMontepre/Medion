using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Sale.Domain.Entities;
using Sale.Domain.Identifiers;
using Sale.Domain.Identifiers.Id;
using Sale.Infrastructure.Persistence.Converters;

namespace Sale.Infrastructure.Persistence.Configurations;

public class OrderConfiguration : IEntityTypeConfiguration<Order>
{
  public void Configure(EntityTypeBuilder<Order> builder)
  {
    builder.HasKey(o => o.Id);

    builder.Property(o => o.Id)
        .HasConversion(new StronglyTypedIdValueConverter<OrderId>());

    builder.Property(o => o.CustomerId)
        .HasConversion(new StronglyTypedIdValueConverter<CustomerId>());

    builder.Property(o => o.SalesStaffId)
        .HasConversion(new StronglyTypedIdValueConverter<UserId>());

    builder.Property(o => o.CreatedBy)
        .HasConversion(new NullableStronglyTypedIdValueConverter<UserId>());

    builder.Property(o => o.UpdatedBy)
        .HasConversion(new NullableStronglyTypedIdValueConverter<UserId>());

    builder.Property(o => o.DeletedBy)
        .HasConversion(new NullableStronglyTypedIdValueConverter<UserId>());

    builder.Property(o => o.SignedBy)
        .HasConversion(new NullableStronglyTypedIdValueConverter<UserId>());

    builder.Property(o => o.OrderNumber)
        .IsRequired()
        .HasMaxLength(30);

    builder.HasIndex(o => o.OrderNumber)
        .IsUnique();

    builder.Property(o => o.Status)
        .HasConversion<string>()
        .HasMaxLength(20);

    builder.Property(o => o.Signature)
        .HasColumnType("bytea");

    builder.Property(o => o.SignaturePublicKey)
        .HasMaxLength(500);

    builder.HasMany(o => o.Items)
        .WithOne()
        .HasForeignKey(oi => oi.OrderId)
        .OnDelete(DeleteBehavior.Cascade);

    builder.Navigation(o => o.Items)
        .UsePropertyAccessMode(PropertyAccessMode.Field);
  }
}
