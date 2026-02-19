using System.ComponentModel;

namespace Sale.Domain.Identifiers.Id;

/// <summary>
///     Strongly-typed identifier for customer signature records.
///     Ensures type safety and separation of concerns in the domain model.
/// </summary>
[TypeConverter(typeof(StronglyTypedIdTypeConverter<CustomerSignatureId>))]
public readonly record struct CustomerSignatureId(Guid Value) : IStronglyTypedId, IParsable<CustomerSignatureId>
{
    public static CustomerSignatureId Empty => new(Guid.Empty);
    public bool IsEmpty => Value == Guid.Empty;

    public static CustomerSignatureId Parse(string s, IFormatProvider? provider)
    {
        if (!TryParse(s, provider, out var result))
            throw new FormatException("Invalid CustomerSignatureId format.");
        return result;
    }

    public static bool TryParse(string? s, IFormatProvider? provider, out CustomerSignatureId result)
    {
        result = Empty;
        if (string.IsNullOrWhiteSpace(s))
            return false;

        var trimmed = s.Trim();
        if (trimmed.StartsWith("value,", StringComparison.OrdinalIgnoreCase))
            trimmed = trimmed["value,".Length..];

        if (!Guid.TryParse(trimmed, out var guid))
            return false;

        result = new CustomerSignatureId(guid);
        return true;
    }

    public static CustomerSignatureId New()
    {
        return new CustomerSignatureId(Guid.CreateVersion7());
    }

    public static CustomerSignatureId Parse(string value)
    {
        return Parse(value, null);
    }

    public override string ToString()
    {
        return Value.ToString();
    }
}
