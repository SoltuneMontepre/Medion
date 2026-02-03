namespace Identity.Application.Common.DTOs;

/// <summary>
///     DTO for user login
/// </summary>
public class LoginDto
{
    public string UserNameOrEmail { get; set; } = null!;
    public string Password { get; set; } = null!;
}
