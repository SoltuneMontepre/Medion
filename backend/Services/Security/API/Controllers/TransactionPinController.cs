using System.Security.Claims;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Security.Application.Features.TransactionPin.Commands;

namespace Security.API.Controllers;

[ApiController]
[Route("api/v1/security/transaction-pin")]
[Authorize]
public class TransactionPinController(IMediator mediator) : ControllerBase
{
    [HttpPost("setup")]
    public async Task<IActionResult> Setup([FromBody] SetupTransactionPinRequest request,
        CancellationToken cancellationToken,
        [FromServices] ILogger<TransactionPinController> logger)
    {
        // Lấy userId từ JWT claims
        var userIdClaim = User.FindFirst("sub")
                            ?? User.FindFirst(ClaimTypes.NameIdentifier)
                            ?? User.FindFirst("preferred_username");

        if (userIdClaim == null)
        {
            logger.LogWarning("JWT does not contain user ID claim. Available claims: {Claims}",
                string.Join(", ", User.Claims.Select(c => c.Type)));

            return Unauthorized(new
            {
                error = "User ID not found in token. This endpoint requires user authentication, not client credentials.",
                hint = "Please authenticate with a user account (not service account) to get a token with 'sub' claim.",
                availableClaims = User.Claims.Select(c => new { c.Type, c.Value }).ToList()
            });
        }

        if (!Guid.TryParse(userIdClaim.Value, out var userId))
        {
            return BadRequest(new
            {
                error = $"User ID from claim '{userIdClaim.Type}' with value '{userIdClaim.Value}' is not a valid GUID"
            });
        }

        logger.LogInformation("Setting up transaction PIN for user {UserId}", userId);

        var command = new SetupTransactionPinCommand(userId, request.PlainPin);
        await mediator.Send(command, cancellationToken);

        return Ok(new { message = "Transaction PIN setup completed", userId });
    }
}

public record SetupTransactionPinRequest(string PlainPin);
