using System.ComponentModel;
using System.Globalization;

namespace Sale.Domain.Identifiers;

public sealed class StronglyTypedIdTypeConverter<TId> : TypeConverter
    where TId : struct, IStronglyTypedId
{
    public override bool CanConvertFrom(ITypeDescriptorContext? context, Type sourceType)
    {
        return sourceType == typeof(string) || sourceType == typeof(Guid) || base.CanConvertFrom(context, sourceType);
    }

    public override bool CanConvertTo(ITypeDescriptorContext? context, Type? destinationType)
    {
        return destinationType == typeof(string) || destinationType == typeof(Guid) ||
               base.CanConvertTo(context, destinationType);
    }

    public override object? ConvertFrom(ITypeDescriptorContext? context, CultureInfo? culture, object value)
    {
        if (value is string stringValue)
            return CreateId(Guid.Parse(stringValue));
        if (value is Guid guidValue)
            return CreateId(guidValue);

        return base.ConvertFrom(context, culture, value);
    }

    public override object? ConvertTo(ITypeDescriptorContext? context, CultureInfo? culture, object? value,
        Type destinationType)
    {
        if (value is not TId idValue)
            return base.ConvertTo(context, culture, value, destinationType);

        if (destinationType == typeof(string))
            return idValue.Value.ToString();
        if (destinationType == typeof(Guid))
            return idValue.Value;

        return base.ConvertTo(context, culture, value, destinationType);
    }

    private static TId CreateId(Guid value)
    {
        return (TId)Activator.CreateInstance(typeof(TId), value)!;
    }
}
