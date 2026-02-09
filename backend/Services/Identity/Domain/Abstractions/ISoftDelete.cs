using Identity.Domain.Identifiers;

namespace Identity.Domain.Abstractions;

public interface ISoftDelete
{
    bool IsDeleted { get; }
    DateTime? DeletedAt { get; }
    IdentityId? DeletedBy { get; }
}
