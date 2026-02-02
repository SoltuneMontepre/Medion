namespace Identity.Application.Common.DTOs;

/// <summary>
///     DTO for user registration
/// </summary>
public class RegisterUserDto
{
    public string Email { get; set; } = null!;
    public string UserName { get; set; } = null!;
    public string Password { get; set; } = null!;
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string? PhoneNumber { get; set; }
    public string? Department { get; set; }
}
