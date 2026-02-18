using System.ComponentModel;

namespace Sale.Domain.Identifiers.Id;

[TypeConverter(typeof(StronglyTypedIdTypeConverter<CustomerId>))]
public readonly record struct CustomerId(Guid Value) : IStronglyTypedId, IParsable<CustomerId>
{
    public static CustomerId Empty => new(Guid.Empty);
    public bool IsEmpty => Value == Guid.Empty;

    public static CustomerId Parse(string s, IFormatProvider? provider)
    {
        if (!TryParse(s, provider, out var result))
            throw new FormatException("Invalid CustomerId format.");
        return result;
    }

    public static bool TryParse(string? s, IFormatProvider? provider, out CustomerId result)
    {
        result = Empty;
        if (string.IsNullOrWhiteSpace(s))
            return false;

        var trimmed = s.Trim();
        if (trimmed.StartsWith("value,", StringComparison.OrdinalIgnoreCase))
            trimmed = trimmed["value,".Length..];

        if (!Guid.TryParse(trimmed, out var guid))
            return false;

        result = new CustomerId(guid);
        return true;
    }

    public static CustomerId New()
    {
        return new CustomerId(Guid.CreateVersion7());
    }

    public static CustomerId Parse(string value)
    {
        return Parse(value, null);
    }

    public override string ToString()
    {
        return Value.ToString();
    }
}
