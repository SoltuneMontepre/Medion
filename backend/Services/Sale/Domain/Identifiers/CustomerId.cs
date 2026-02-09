using System.ComponentModel;

namespace Sale.Domain.Identifiers;

[TypeConverter(typeof(StronglyTypedIdTypeConverter<CustomerId>))]
public readonly record struct CustomerId(Guid Value) : IStronglyTypedId
{
    public static CustomerId New() => new(Guid.CreateVersion7());
    public static CustomerId Empty => new(Guid.Empty);
    public bool IsEmpty => Value == Guid.Empty;

    public static CustomerId Parse(string value) => new(Guid.Parse(value));
    public override string ToString() => Value.ToString();
}
