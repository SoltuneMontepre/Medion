namespace Security.Domain.Entities;

/// <summary>
///     Represents a user's transaction PIN security profile.
/// </summary>
public sealed class UserSecurityProfile
{
  public Guid UserId { get; set; }
  public string TransactionPinHash { get; set; } = null!;
  public DateTime CreatedAt { get; set; }
  public DateTime? UpdatedAt { get; set; }
}
