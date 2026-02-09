using Identity.Domain.Abstractions;
using Identity.Domain.Identifiers;
using Microsoft.AspNetCore.Identity;

namespace Identity.Domain.Entities;

/// <summary>
///     User entity representing an identity in the system
///     Extends BaseEntity for audit trails and soft delete support
/// </summary>
public sealed class User : IdentityUser<IdentityId>, IAuditable, ISoftDelete
{
    public User()
    {
        Id = IdentityId.New();
    }

    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string? ProfilePictureUrl { get; set; }
    public string? Department { get; set; }
    public bool IsActive { get; set; } = true;

    /// <summary>
    ///     Navigation property for user claims
    /// </summary>
    public ICollection<UserClaim> Claims { get; set; } = [];

    /// <summary>
    ///     Navigation property for user roles
    /// </summary>
    public ICollection<UserRole> Roles { get; set; } = [];

    // IAuditable members
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public IdentityId? CreatedBy { get; set; }
    public IdentityId? UpdatedBy { get; set; }

    // ISoftDelete members
    public bool IsDeleted { get; set; }
    public DateTime? DeletedAt { get; set; }
    public IdentityId? DeletedBy { get; set; }

    public static User Create(string email, string userName, string firstName, string lastName)
    {
        return new User
        {
            Email = email,
            NormalizedEmail = email.ToUpper(),
            UserName = userName,
            NormalizedUserName = userName.ToUpper(),
            FirstName = firstName,
            LastName = lastName,
            EmailConfirmed = false,
            PhoneNumberConfirmed = false,
            TwoFactorEnabled = false,
            LockoutEnabled = true,
            AccessFailedCount = 0
        };
    }

    public void UpdateEmail(string email)
    {
        Email = email;
        NormalizedEmail = email.ToUpper();
        EmailConfirmed = false;
    }

    public void UpdateProfile(string firstName, string lastName, string? phoneNumber = null)
    {
        FirstName = firstName;
        LastName = lastName;
        if (!string.IsNullOrWhiteSpace(phoneNumber)) PhoneNumber = phoneNumber;
    }

    public void SetPassword(string passwordHash)
    {
        PasswordHash = passwordHash;
        AccessFailedCount = 0;
    }

    public void LockAccount()
    {
        LockoutEnd = DateTimeOffset.UtcNow.AddHours(1);
    }

    public void UnlockAccount()
    {
        LockoutEnd = null;
        AccessFailedCount = 0;
    }

    public void ConfirmEmail()
    {
        EmailConfirmed = true;
    }

    public void ConfirmPhoneNumber()
    {
        PhoneNumberConfirmed = true;
    }

    public void IncrementFailedLoginAttempt()
    {
        AccessFailedCount++;
        if (AccessFailedCount >= 5) LockAccount();
    }

    public void Deactivate()
    {
        IsActive = false;
    }

    public void Activate()
    {
        IsActive = true;
    }
}
