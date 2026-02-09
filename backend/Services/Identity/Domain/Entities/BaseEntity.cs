using Identity.Domain.Abstractions;
using Identity.Domain.Identifiers;

namespace Identity.Domain.Entities;

public abstract class BaseEntity : IAuditable, ISoftDelete
{
    public IdentityId Id { get; protected set; } = IdentityId.New();

    // IAuditable members
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public IdentityId? CreatedBy { get; set; }
    public IdentityId? UpdatedBy { get; set; }

    // ISoftDelete members
    public bool IsDeleted { get; set; }
    public DateTime? DeletedAt { get; set; }
    public IdentityId? DeletedBy { get; set; }
}
