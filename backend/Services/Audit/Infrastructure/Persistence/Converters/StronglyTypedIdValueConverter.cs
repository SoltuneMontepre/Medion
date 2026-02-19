using Audit.Domain.Identifiers;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace Audit.Infrastructure.Persistence.Converters;

/// <summary>
///     EF Core value converter for strongly-typed IDs.
///     Converts between the domain type (e.g., GlobalAuditLogId) and the database UUID type.
/// </summary>
public sealed class StronglyTypedIdValueConverter<TId> : ValueConverter<TId, Guid>
    where TId : struct, IStronglyTypedId
{
  public StronglyTypedIdValueConverter()
      : base(
          id => id.Value,
          value => (TId)Activator.CreateInstance(typeof(TId), value)!,
          new ConverterMappingHints(size: 36))
  {
  }
}

/// <summary>
///     EF Core value converter for nullable strongly-typed IDs.
///     Converts between the domain type and the database UUID type.
/// </summary>
public sealed class NullableStronglyTypedIdValueConverter<TId> : ValueConverter<TId?, Guid?>
    where TId : struct, IStronglyTypedId
{
  public NullableStronglyTypedIdValueConverter()
      : base(
          id => id.HasValue ? id.Value.Value : null,
          value => value.HasValue ? (TId)Activator.CreateInstance(typeof(TId), value.Value)! : null,
          new ConverterMappingHints(size: 36))
  {
  }
}
