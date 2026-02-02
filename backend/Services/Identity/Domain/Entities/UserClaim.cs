namespace Identity.Domain.Entities;

/// <summary>
///     Represents a claim associated with a user
/// </summary>
public class UserClaim : BaseEntity
{
    private UserClaim()
    {
    }

    public Guid UserId { get; set; }
    public string ClaimType { get; set; } = null!;
    public string ClaimValue { get; set; } = null!;

    // Navigation property
    public User? User { get; set; }

    public static UserClaim Create(Guid userId, string claimType, string claimValue)
    {
        return new UserClaim
        {
            UserId = userId,
            ClaimType = claimType,
            ClaimValue = claimValue
        };
    }
}
