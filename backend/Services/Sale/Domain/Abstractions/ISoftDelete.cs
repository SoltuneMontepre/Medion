using Sale.Domain.Identifiers;

namespace Sale.Domain.Abstractions;

public interface ISoftDelete
{
    bool IsDeleted { get; }
    DateTime? DeletedAt { get; }
    UserId? DeletedBy { get; }
}
