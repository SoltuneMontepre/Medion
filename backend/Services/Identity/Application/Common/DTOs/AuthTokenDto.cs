namespace Identity.Application.Common.DTOs;

/// <summary>
///     DTO for authentication response with JWT token
/// </summary>
public class AuthTokenDto
{
    public string AccessToken { get; set; } = null!;
    public string? RefreshToken { get; set; }
    public string TokenType { get; set; } = "Bearer";
    public int ExpiresIn { get; set; }
    public UserDto User { get; set; } = null!;
}
