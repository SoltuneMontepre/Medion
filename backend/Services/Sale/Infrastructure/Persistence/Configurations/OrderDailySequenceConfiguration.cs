using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Sale.Domain.Entities;

namespace Sale.Infrastructure.Persistence.Configurations;

public class OrderDailySequenceConfiguration : IEntityTypeConfiguration<OrderDailySequence>
{
  public void Configure(EntityTypeBuilder<OrderDailySequence> builder)
  {
    builder.HasKey(x => x.Date);

    builder.Property(x => x.Date)
        .HasColumnType("date");

    builder.Property(x => x.CurrentValue)
        .IsRequired();
  }
}
