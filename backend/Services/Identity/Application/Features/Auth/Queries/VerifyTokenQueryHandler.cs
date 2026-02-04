using Identity.Application.Common.Abstractions;
using Identity.Application.Common.DTOs;

namespace Identity.Application.Features.Auth.Queries;

/// <summary>
///     Handler for VerifyTokenQuery
/// </summary>
public class VerifyTokenQueryHandler(ITokenService tokenService)
    : IRequestHandler<VerifyTokenQuery, TokenVerificationDto>
{
    public async Task<TokenVerificationDto> Handle(VerifyTokenQuery request, CancellationToken cancellationToken)
    {
        var isValid = await tokenService.ValidateTokenAsync(request.Token, cancellationToken);

        if (!isValid) return new TokenVerificationDto { IsValid = false };

        // Extract claims from token and populate DTO
        // This implementation depends on your JWT configuration
        // You'll need to extract and parse claims from the token

        return new TokenVerificationDto
        {
            IsValid = true
        };
    }
}
