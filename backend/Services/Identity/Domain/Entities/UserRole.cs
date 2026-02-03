namespace Identity.Domain.Entities;

/// <summary>
///     Join table between User and Role
/// </summary>
public class UserRole : BaseEntity
{
    private UserRole()
    {
    }

    public Guid UserId { get; set; }
    public Guid RoleId { get; set; }

    // Navigation properties
    public User? User { get; set; }
    public Role? Role { get; set; }

    public static UserRole Create(Guid userId, Guid roleId)
    {
        return new UserRole
        {
            UserId = userId,
            RoleId = roleId
        };
    }
}
