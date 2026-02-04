using Identity.Application.Common.Abstractions;
using Identity.Application.Common.DTOs;
using Identity.Application.Features.Auth.Commands;
using Identity.Application.Features.Auth.Queries;
using ServiceDefaults.ApiResponses;

namespace Identity.API.Controllers;

/// <summary>
///     Authentication controller
///     Handles registration, login, and token verification
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class AuthController(IMediator mediator, ITokenBlacklistService tokenBlacklistService) : ApiControllerBase
{
    /// <summary>
    ///     Register a new user
    /// </summary>
    [HttpPost("register")]
    [ProducesResponseType(StatusCodes.Status201Created, Type = typeof(ApiResult<UserDto>))]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Register([FromBody] RegisterUserDto request, CancellationToken cancellationToken)
    {
        var command = new RegisterUserCommand(request);
        var result = await mediator.Send(command, cancellationToken);

        if (result.IsSuccess && result.Data != null)
            return Created(nameof(GetUser), new { userId = result.Data.Id }, result.Data,
                "User registered successfully");

        return BadRequest<UserDto>("Registration failed");
    }

    /// <summary>
    ///     Login user and get JWT token
    ///     Returns accessToken in body and sets refreshToken in HttpOnly cookie
    /// </summary>
    [HttpPost("login")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<AuthTokenDto>))]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Login([FromBody] LoginDto loginDto, CancellationToken cancellationToken)
    {
        var command = new LoginCommand(loginDto);
        var result = await mediator.Send(command, cancellationToken);

        if (!result.IsSuccess || result.Data == null)
            if (result.Message != null)
                return ApiResponse(ApiResult<AuthTokenDto>.Failure(result.Message, result.StatusCode, result.Errors));
        // Set refresh token in HttpOnly cookie
        Response.Cookies.Append("refreshToken", result.Data?.RefreshToken!, new CookieOptions
        {
            HttpOnly = true,
            Secure = true,
            SameSite = SameSiteMode.Strict,
            Path = "/api/auth/refresh",
            Expires = DateTime.UtcNow.AddDays(7)
        });

        // Return only AuthToken DTO in response (without refreshToken)
        return ApiResponse(ApiResult<AuthTokenDto>.Success(result.Data!.AuthToken, result.Message));
    }

    /// <summary>
    ///     Get current authenticated user information from JWT claims
    /// </summary>
    [Authorize]
    [HttpGet("me")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<UserDto>))]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public IActionResult GetCurrentUser()
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var email = User.FindFirst(ClaimTypes.Email)?.Value;
        var userName = User.FindFirst(ClaimTypes.Name)?.Value;
        var firstName = User.FindFirst("FirstName")?.Value;
        var lastName = User.FindFirst("LastName")?.Value;
        var emailConfirmed = bool.Parse(User.FindFirst(ClaimTypes.Email + "Confirmed")?.Value ?? "false");
        var phoneNumberConfirmed = bool.Parse(User.FindFirst("PhoneNumberConfirmed")?.Value ?? "false");
        var roles = User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();

        var userDto = new UserDto
        {
            Id = Guid.Parse(userId!),
            Email = email!,
            UserName = userName!,
            FirstName = firstName!,
            LastName = lastName!,
            EmailConfirmed = emailConfirmed,
            PhoneNumberConfirmed = phoneNumberConfirmed,
            Roles = roles
        };

        return Ok(userDto, "User information retrieved successfully");
    }

    /// <summary>
    ///     Get current user information by user ID
    /// </summary>
    [Authorize]
    [HttpGet("user/{userId}")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<UserDto>))]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetUser(Guid userId, CancellationToken cancellationToken)
    {
        var query = new GetUserByIdQuery(userId);
        var result = await mediator.Send(query, cancellationToken);
        return Ok(result, "User retrieved successfully");
    }

    /// <summary>
    ///     Verify JWT token and get user claims
    ///     Used by other microservices via gRPC
    /// </summary>
    [HttpPost("verify")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(TokenVerificationDto))]
    public async Task<IActionResult> VerifyToken([FromBody] string token, CancellationToken cancellationToken)
    {
        var query = new VerifyTokenQuery { Token = token };
        var result = await mediator.Send(query, cancellationToken);
        return Ok(result);
    }

    /// <summary>
    ///     Refresh access token using refresh token from cookie
    /// </summary>
    [HttpPost("refresh")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<AuthTokenDto>))]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> RefreshToken(CancellationToken cancellationToken)
    {
        // Get refresh token from cookie
        if (!Request.Cookies.TryGetValue("refreshToken", out var refreshToken))
            return Unauthorized<AuthTokenDto>("Refresh token not found");

        var command = new RefreshTokenCommand { RefreshToken = refreshToken };
        var result = await mediator.Send(command, cancellationToken);

        // Update refresh token cookie if new one is generated
        if (result.IsSuccess && result.Data?.RefreshToken != null)
        {
            var cookieOptions = new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Path = "/api/auth/refresh",
                Expires = DateTimeOffset.UtcNow.AddDays(7)
            };

            Response.Cookies.Append("refreshToken", result.Data.RefreshToken, cookieOptions);
            result.Data.RefreshToken = null;
        }

        return ApiResponse(result);
    }

    /// <summary>
    ///     Logout user by clearing refresh token cookie and blacklisting access token
    /// </summary>
    [Authorize]
    [HttpPost("logout")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> Logout()
    {
        // Get access token from Authorization header
        var authHeader = Request.Headers.Authorization.FirstOrDefault();

        if (!string.IsNullOrEmpty(authHeader) && authHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
        {
            var token = authHeader["Bearer ".Length..].Trim();

            // Parse token to get expiration date
            var tokenHandler = new JwtSecurityTokenHandler();

            try
            {
                var jwtToken = tokenHandler.ReadJwtToken(token);
                var expiryDate = jwtToken.ValidTo;

                // Add token to blacklist
                await tokenBlacklistService.AddToBlacklistAsync(token, expiryDate);
            }
            catch (Exception)
            {
                // If token parsing fails, ignore and continue with logout
                // Token might already be invalid
            }
        }

        // Clear refresh token cookie
        Response.Cookies.Delete("refreshToken", new CookieOptions
        {
            Path = "/api/auth/refresh"
        });

        return Ok(new { message = "Logged out successfully" });
    }
}
