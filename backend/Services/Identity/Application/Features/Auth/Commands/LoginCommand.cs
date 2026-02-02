using Identity.Application.Common.DTOs;
using MediatR;

namespace Identity.Application.Features.Auth.Commands;

/// <summary>
///     Command for user login
/// </summary>
public class LoginCommand : IRequest<AuthTokenDto>
{
    public LoginCommand()
    {
    }

    public LoginCommand(LoginDto dto)
    {
        UserNameOrEmail = dto.UserNameOrEmail;
        Password = dto.Password;
    }

    public string UserNameOrEmail { get; set; } = null!;
    public string Password { get; set; } = null!;
}
