using Identity.Domain.Abstractions;
using Identity.Domain.Identifiers;
using Microsoft.AspNetCore.Identity;

namespace Identity.Domain.Entities;

/// <summary>
///     Represents a role in the system
/// </summary>
public sealed class Role : IdentityRole<IdentityId>, IAuditable, ISoftDelete
{
    public Role()
    {
        Id = IdentityId.New();
    }

    public string? Description { get; set; }

    public ICollection<UserRole> UserRoles { get; set; } = [];
    public ICollection<RoleClaim> Claims { get; set; } = [];

    // IAuditable members
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public IdentityId? CreatedBy { get; set; }
    public IdentityId? UpdatedBy { get; set; }

    // ISoftDelete members
    public bool IsDeleted { get; set; }
    public DateTime? DeletedAt { get; set; }
    public IdentityId? DeletedBy { get; set; }

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
