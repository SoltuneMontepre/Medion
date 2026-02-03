using Identity.Application.Common.DTOs;
using ServiceDefaults.ApiResponses;

namespace Identity.Application.Features.Auth.Commands;

/// <summary>
///     Internal result for login command including refresh token
///     Refresh token is used to set HttpOnly cookie, not returned in API response
/// </summary>
public class LoginResult
{
    public AuthTokenDto AuthToken { get; set; } = null!;
    public string RefreshToken { get; set; } = null!;
}
