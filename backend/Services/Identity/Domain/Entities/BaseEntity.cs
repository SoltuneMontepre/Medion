using Identity.Domain.Abstractions;

namespace Identity.Domain.Entities;

public abstract class BaseEntity : IAuditable, ISoftDelete
{
    protected BaseEntity()
    {
        Id = Guid.CreateVersion7();
    }

    public Guid Id { get; protected set; }

    // IAuditable members
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public Guid? CreatedBy { get; set; }
    public Guid? UpdatedBy { get; set; }

    // ISoftDelete members
    public bool IsDeleted { get; set; }
    public DateTime? DeletedAt { get; set; }
    public Guid? DeletedBy { get; set; }
}
