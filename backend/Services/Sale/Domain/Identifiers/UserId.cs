using System.ComponentModel;

namespace Sale.Domain.Identifiers;

[TypeConverter(typeof(StronglyTypedIdTypeConverter<UserId>))]
public readonly record struct UserId(Guid Value) : IStronglyTypedId
{
    public static UserId New() => new(Guid.CreateVersion7());
    public static UserId Empty => new(Guid.Empty);
    public bool IsEmpty => Value == Guid.Empty;

    public static UserId Parse(string value) => new(Guid.Parse(value));
    public override string ToString() => Value.ToString();
}
