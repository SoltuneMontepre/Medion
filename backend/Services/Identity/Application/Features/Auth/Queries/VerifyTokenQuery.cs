using Identity.Application.Common.DTOs;

namespace Identity.Application.Features.Auth.Queries;

/// <summary>
///     Query to verify JWT token and return user info
///     Used by other services via gRPC
/// </summary>
public class VerifyTokenQuery : IRequest<TokenVerificationDto>
{
    public string Token { get; set; } = null!;
}
