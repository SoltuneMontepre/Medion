using Identity.Application.Common.DTOs;
using MediatR;
using ServiceDefaults.ApiResponses;

namespace Identity.Application.Features.Auth.Commands;

/// <summary>
///     Command to refresh JWT token
/// </summary>
public class RefreshTokenCommand : IRequest<ApiResult<LoginResult>>
{
    public string RefreshToken { get; set; } = null!;
}
