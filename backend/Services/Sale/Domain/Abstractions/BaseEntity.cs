using Sale.Domain.Identifiers;

namespace Sale.Domain.Abstractions;

public abstract class BaseEntity<TId> : IAuditable, ISoftDelete
    where TId : struct, IStronglyTypedId
{
    public TId Id { get; protected set; }

    // IAuditable members
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public UserId? CreatedBy { get; set; }
    public UserId? UpdatedBy { get; set; }

    // ISoftDelete members
    public bool IsDeleted { get; set; }
    public DateTime? DeletedAt { get; set; }
    public UserId? DeletedBy { get; set; }
}
