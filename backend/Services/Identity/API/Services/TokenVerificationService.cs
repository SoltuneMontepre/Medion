using Grpc.Core;
using Identity.Application.Features.Auth.Queries;
using MediatR;
using Services.Identity.API.Grpc;

namespace Identity.API.Services;

/// <summary>
///     gRPC service for token verification
///     Allows other services to verify tokens and get user information
/// </summary>
public class TokenVerificationService : TokenVerification.TokenVerificationBase
{
    private readonly ILogger<TokenVerificationService> _logger;
    private readonly IMediator _mediator;

    public TokenVerificationService(IMediator mediator, ILogger<TokenVerificationService> logger)
    {
        _mediator = mediator;
        _logger = logger;
    }

    /// <summary>
    ///     Verify a JWT token and return user information
    /// </summary>
    public override async Task<VerifyTokenResponse> VerifyToken(VerifyTokenRequest request, ServerCallContext context)
    {
        try
        {
            var query = new VerifyTokenQuery { Token = request.Token };
            var result = await _mediator.Send(query, context.CancellationToken);

            if (!result.IsValid)
                return new VerifyTokenResponse
                {
                    IsValid = false
                };

            var response = new VerifyTokenResponse
            {
                IsValid = true,
                UserId = result.UserId.ToString(),
                UserName = result.UserName,
                Email = result.Email
            };

            response.Roles.AddRange(result.Roles);
            response.Permissions.AddRange(result.Permissions);

            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error verifying token");
            return new VerifyTokenResponse
            {
                IsValid = false
            };
        }
    }
}
