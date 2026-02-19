using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using Sale.Domain.Identifiers;

namespace Sale.Infrastructure.Persistence.Converters;

public sealed class StronglyTypedIdValueConverter<TId> : ValueConverter<TId, Guid>
    where TId : struct, IStronglyTypedId
{
    public StronglyTypedIdValueConverter()
        : base(id => id.Value, value => (TId)Activator.CreateInstance(typeof(TId), value)!,
            new ConverterMappingHints(36))
    {
    }
}

public sealed class NullableStronglyTypedIdValueConverter<TId> : ValueConverter<TId?, Guid?>
    where TId : struct, IStronglyTypedId
{
    public NullableStronglyTypedIdValueConverter()
        : base(id => id.HasValue ? id.Value.Value : null,
            value => value.HasValue ? (TId)Activator.CreateInstance(typeof(TId), value.Value)! : null,
            new ConverterMappingHints(36))
    {
    }
}
