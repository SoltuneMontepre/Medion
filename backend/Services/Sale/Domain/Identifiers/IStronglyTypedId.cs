namespace Sale.Domain.Identifiers;

public interface IStronglyTypedId
{
    Guid Value { get; }
}
