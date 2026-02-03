namespace Identity.Application.Common.DTOs;

/// <summary>
///     DTO for authentication response with JWT token
/// </summary>
public class AuthTokenDto
{
    public string AccessToken { get; set; } = null!;
    public int ExpiresIn { get; set; }
}
