using System.ComponentModel;

namespace Identity.Domain.Identifiers;

[TypeConverter(typeof(StronglyTypedIdTypeConverter<IdentityId>))]
public readonly record struct IdentityId(Guid Value) : IStronglyTypedId
{
    public static IdentityId New() => new(Guid.CreateVersion7());
    public static IdentityId Empty => new(Guid.Empty);
    public bool IsEmpty => Value == Guid.Empty;

    public static IdentityId Parse(string value) => new(Guid.Parse(value));
    public override string ToString() => Value.ToString();
}
