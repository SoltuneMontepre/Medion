using Identity.Application.Common.Abstractions;

namespace Identity.API.Filters;

/// <summary>
///     Authorization filter to check if the JWT token is blacklisted
///     Apply this filter to endpoints that need to check token revocation
/// </summary>
public class CheckTokenBlacklistFilter(ITokenBlacklistService tokenBlacklistService) : IAsyncAuthorizationFilter
{
    public async Task OnAuthorizationAsync(AuthorizationFilterContext context)
    {
        // Skip if endpoint allows anonymous access
        var allowAnonymous = context.ActionDescriptor.EndpointMetadata
            .Any(m => m is IAllowAnonymous);

        if (allowAnonymous) return;

        // Get token from Authorization header
        var authHeader = context.HttpContext.Request.Headers.Authorization.FirstOrDefault();

        if (string.IsNullOrEmpty(authHeader) ||
            !authHeader.StartsWith("Bearer ",
                StringComparison.OrdinalIgnoreCase)) return; // Let the authentication middleware handle this

        var token = authHeader["Bearer ".Length..].Trim();

        // Check if token is blacklisted
        var isBlacklisted = await tokenBlacklistService.IsBlacklistedAsync(token);

        if (isBlacklisted)
            context.Result = new UnauthorizedObjectResult(new
            {
                error = "Token has been revoked. Please login again.",
                type = "token_revoked"
            });
    }
}
