using Identity.Domain.Identifiers;

namespace Identity.Domain.Entities;

/// <summary>
///     Represents a claim associated with a user
/// </summary>
public class UserClaim : BaseEntity
{
    private UserClaim()
    {
    }

    public IdentityId UserId { get; set; }
    public string ClaimType { get; set; } = null!;
    public string ClaimValue { get; set; } = null!;

    // Navigation property
    public User? User { get; set; }

    public static UserClaim Create(IdentityId userId, string claimType, string claimValue)
    {
        return new UserClaim
        {
            UserId = userId,
            ClaimType = claimType,
            ClaimValue = claimValue
        };
    }
}
