using MediatR;
using Microsoft.AspNetCore.Mvc;
using Security.Application.Features.TransactionPin.Commands;

namespace Security.API.Controllers;

[ApiController]
[Route("api/v1/security/transaction-pin")]
public class TransactionPinController(IMediator mediator) : ControllerBase
{
    [HttpPost("setup")]
    public async Task<IActionResult> Setup([FromBody] SetupTransactionPinCommand command, CancellationToken cancellationToken)
    {
        await mediator.Send(command, cancellationToken);
        return Ok(new { message = "Transaction PIN setup completed" });
    }
}
