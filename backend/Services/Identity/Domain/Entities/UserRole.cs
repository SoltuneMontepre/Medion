using Identity.Domain.Identifiers;

namespace Identity.Domain.Entities;

/// <summary>
///     Join table between User and Role
/// </summary>
public class UserRole : BaseEntity
{
    private UserRole()
    {
    }

    public IdentityId UserId { get; set; }
    public IdentityId RoleId { get; set; }

    // Navigation properties
    public User? User { get; set; }
    public Role? Role { get; set; }

    public static UserRole Create(IdentityId userId, IdentityId roleId)
    {
        return new UserRole
        {
            UserId = userId,
            RoleId = roleId
        };
    }
}
