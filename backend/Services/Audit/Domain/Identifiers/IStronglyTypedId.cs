namespace Audit.Domain.Identifiers;

/// <summary>
///     Marker interface for strongly-typed identifiers.
///     Provides type safety and domain semantics for aggregate root identifiers.
/// </summary>
public interface IStronglyTypedId
{
  Guid Value { get; }
}
