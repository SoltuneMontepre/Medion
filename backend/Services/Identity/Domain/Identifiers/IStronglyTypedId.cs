namespace Identity.Domain.Identifiers;

public interface IStronglyTypedId
{
    Guid Value { get; }
}
