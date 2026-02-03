namespace Identity.Application.Common.DTOs;

/// <summary>
///     DTO for token verification response (used by gRPC services)
/// </summary>
public class TokenVerificationDto
{
    public bool IsValid { get; set; }
    public Guid UserId { get; set; }
    public string UserName { get; set; } = null!;
    public string Email { get; set; } = null!;
    public ICollection<string> Roles { get; set; } = new List<string>();
    public ICollection<string> Permissions { get; set; } = new List<string>();
}
