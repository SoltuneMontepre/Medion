using Identity.Application.Common.DTOs;
using MediatR;
using ServiceDefaults.ApiResponses;

namespace Identity.Application.Features.Auth.Commands;

/// <summary>
///     Command to register a new user
/// </summary>
public class RegisterUserCommand : IRequest<ApiResult<UserDto>>
{
    public RegisterUserCommand()
    {
    }

    public RegisterUserCommand(RegisterUserDto dto)
    {
        Email = dto.Email;
        UserName = dto.UserName;
        Password = dto.Password;
        FirstName = dto.FirstName;
        LastName = dto.LastName;
        PhoneNumber = dto.PhoneNumber;
        Department = dto.Department;
    }

    public string Email { get; set; } = null!;
    public string UserName { get; set; } = null!;
    public string Password { get; set; } = null!;
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string? PhoneNumber { get; set; }
    public string? Department { get; set; }
}
