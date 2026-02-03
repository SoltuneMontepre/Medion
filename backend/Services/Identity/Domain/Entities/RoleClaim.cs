namespace Identity.Domain.Entities;

/// <summary>
///     Represents a claim associated with a role
/// </summary>
public class RoleClaim : BaseEntity
{
    private RoleClaim()
    {
    }

    public Guid RoleId { get; set; }
    public string ClaimType { get; set; } = null!;
    public string ClaimValue { get; set; } = null!;

    // Navigation property
    public Role? Role { get; set; }

    public static RoleClaim Create(Guid roleId, string claimType, string claimValue)
    {
        return new RoleClaim
        {
            RoleId = roleId,
            ClaimType = claimType,
            ClaimValue = claimValue
        };
    }
}
