namespace Sale.Domain.Abstractions;

public abstract class BaseEntity : IAuditable, ISoftDelete
{
    public Guid Id { get; protected set; } = Guid.CreateVersion7();

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
