using System.ComponentModel;

namespace Sale.Domain.Identifiers.Id;

[TypeConverter(typeof(StronglyTypedIdTypeConverter<OrderId>))]
public readonly record struct OrderId(Guid Value) : IStronglyTypedId, IParsable<OrderId>
{
    public static OrderId Empty => new(Guid.Empty);
    public bool IsEmpty => Value == Guid.Empty;

    public static OrderId Parse(string s, IFormatProvider? provider)
    {
        if (!TryParse(s, provider, out var result))
            throw new FormatException("Invalid OrderId format.");
        return result;
    }

    public static bool TryParse(string? s, IFormatProvider? provider, out OrderId result)
    {
        result = Empty;
        if (string.IsNullOrWhiteSpace(s))
            return false;

        var trimmed = s.Trim();
        if (trimmed.StartsWith("value,", StringComparison.OrdinalIgnoreCase))
            trimmed = trimmed["value,".Length..];

        if (!Guid.TryParse(trimmed, out var guid))
            return false;

        result = new OrderId(guid);
        return true;
    }

    public static OrderId New()
    {
        return new OrderId(Guid.CreateVersion7());
    }

    public static OrderId Parse(string value)
    {
        return Parse(value, null);
    }

    public override string ToString()
    {
        return Value.ToString();
    }
}
