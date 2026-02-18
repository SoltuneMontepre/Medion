using System.ComponentModel;

namespace Sale.Domain.Identifiers.Id;

[TypeConverter(typeof(StronglyTypedIdTypeConverter<ProductId>))]
public readonly record struct ProductId(Guid Value) : IStronglyTypedId, IParsable<ProductId>
{
    public static ProductId Empty => new(Guid.Empty);
    public bool IsEmpty => Value == Guid.Empty;

    public static ProductId Parse(string s, IFormatProvider? provider)
    {
        if (!TryParse(s, provider, out var result))
            throw new FormatException("Invalid ProductId format.");
        return result;
    }

    public static bool TryParse(string? s, IFormatProvider? provider, out ProductId result)
    {
        result = Empty;
        if (string.IsNullOrWhiteSpace(s))
            return false;

        var trimmed = s.Trim();
        if (trimmed.StartsWith("value,", StringComparison.OrdinalIgnoreCase))
            trimmed = trimmed["value,".Length..];

        if (!Guid.TryParse(trimmed, out var guid))
            return false;

        result = new ProductId(guid);
        return true;
    }

    public static ProductId New()
    {
        return new ProductId(Guid.CreateVersion7());
    }

    public static ProductId Parse(string value)
    {
        return Parse(value, null);
    }

    public override string ToString()
    {
        return Value.ToString();
    }
}
