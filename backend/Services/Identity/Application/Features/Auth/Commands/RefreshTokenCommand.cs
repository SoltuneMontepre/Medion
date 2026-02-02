using MediatR;

namespace Identity.Application.Features.Auth.Commands;

/// <summary>
///     Command to refresh JWT token
/// </summary>
public class RefreshTokenCommand : IRequest<string>
{
    public string RefreshToken { get; set; } = null!;
}
