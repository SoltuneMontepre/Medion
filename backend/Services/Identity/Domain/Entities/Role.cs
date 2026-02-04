using Identity.Domain.Abstractions;
using Microsoft.AspNetCore.Identity;

namespace Identity.Domain.Entities;

/// <summary>
///     Represents a role in the system
/// </summary>
public sealed class Role : IdentityRole<Guid>, IAuditable, ISoftDelete
{
    public Role()
    {
        Id = Guid.CreateVersion7();
    }

    public string? Description { get; set; }

    public ICollection<UserRole> UserRoles { get; set; } = [];
    public ICollection<RoleClaim> Claims { get; set; } = [];

    // IAuditable members
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public Guid? CreatedBy { get; set; }
    public Guid? UpdatedBy { get; set; }

    // ISoftDelete members
    public bool IsDeleted { get; set; }
    public DateTime? DeletedAt { get; set; }
    public Guid? DeletedBy { get; set; }

    public static Role Create(string name, string? description = null)
    {
        return new Role
        {
            Name = name,
            NormalizedName = name.ToUpper(),
            Description = description
        };
    }
}
