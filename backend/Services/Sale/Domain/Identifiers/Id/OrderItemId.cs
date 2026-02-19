using System.ComponentModel;

namespace Sale.Domain.Identifiers.Id;

[TypeConverter(typeof(StronglyTypedIdTypeConverter<OrderItemId>))]
public readonly record struct OrderItemId(Guid Value) : IStronglyTypedId, IParsable<OrderItemId>
{
    public static OrderItemId Empty => new(Guid.Empty);
    public bool IsEmpty => Value == Guid.Empty;

    public static OrderItemId Parse(string s, IFormatProvider? provider)
    {
        if (!TryParse(s, provider, out var result))
            throw new FormatException("Invalid OrderItemId format.");
        return result;
    }

    public static bool TryParse(string? s, IFormatProvider? provider, out OrderItemId result)
    {
        result = Empty;
        if (string.IsNullOrWhiteSpace(s))
            return false;

        var trimmed = s.Trim();
        if (trimmed.StartsWith("value,", StringComparison.OrdinalIgnoreCase))
            trimmed = trimmed["value,".Length..];

        if (!Guid.TryParse(trimmed, out var guid))
            return false;

        result = new OrderItemId(guid);
        return true;
    }

    public static OrderItemId New()
    {
        return new OrderItemId(Guid.CreateVersion7());
    }

    public static OrderItemId Parse(string value)
    {
        return Parse(value, null);
    }

    public override string ToString()
    {
        return Value.ToString();
    }
}
