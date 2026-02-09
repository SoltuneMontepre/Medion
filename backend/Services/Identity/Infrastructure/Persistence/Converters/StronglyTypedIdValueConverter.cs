using Identity.Domain.Identifiers;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace Identity.Infrastructure.Persistence.Converters;

public sealed class StronglyTypedIdValueConverter<TId> : ValueConverter<TId, Guid>
    where TId : struct, IStronglyTypedId
{
    public StronglyTypedIdValueConverter()
        : base(id => id.Value, value => (TId)Activator.CreateInstance(typeof(TId), value)!,
            new ConverterMappingHints(size: 36))
    {
    }
}

public sealed class NullableStronglyTypedIdValueConverter<TId> : ValueConverter<TId?, Guid?>
    where TId : struct, IStronglyTypedId
{
    public NullableStronglyTypedIdValueConverter()
        : base(id => id.HasValue ? id.Value.Value : null,
            value => value.HasValue ? (TId)Activator.CreateInstance(typeof(TId), value.Value)! : null,
            new ConverterMappingHints(size: 36))
    {
    }
}
