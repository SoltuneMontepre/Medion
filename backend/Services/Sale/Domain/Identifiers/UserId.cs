using System.ComponentModel;

namespace Sale.Domain.Identifiers;

[TypeConverter(typeof(StronglyTypedIdTypeConverter<UserId>))]
public readonly record struct UserId(Guid Value) : IStronglyTypedId, IParsable<UserId>
{
    public static UserId Empty => new(Guid.Empty);
    public bool IsEmpty => Value == Guid.Empty;

    public static UserId Parse(string s, IFormatProvider? provider)
    {
        if (!TryParse(s, provider, out var result))
            throw new FormatException("Invalid UserId format.");
        return result;
    }

    public static bool TryParse(string? s, IFormatProvider? provider, out UserId result)
    {
        result = Empty;
        if (string.IsNullOrWhiteSpace(s))
            return false;

        var trimmed = s.Trim();
        if (trimmed.StartsWith("value,", StringComparison.OrdinalIgnoreCase))
            trimmed = trimmed["value,".Length..];

        if (!Guid.TryParse(trimmed, out var guid))
            return false;

        result = new UserId(guid);
        return true;
    }

    public static UserId New()
    {
        return new UserId(Guid.CreateVersion7());
    }

    public static UserId Parse(string value)
    {
        return Parse(value, null);
    }

    public override string ToString()
    {
        return Value.ToString();
    }
}
