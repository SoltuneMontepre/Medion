using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Sale.Application.Common.DTOs;
using Sale.Application.Features.Order.Commands;
using Sale.Application.Features.Order.Queries;
using Sale.Domain.Identifiers;
using ServiceDefaults.ApiResponses;

namespace Sale.API.Controllers;

/// <summary>
///     Order management controller
/// </summary>
[ApiController]
[Route("orders")]
public class OrderController(IMediator mediator) : ApiControllerBase
{
    /// <summary>
    ///     Create and sign a new order
    /// </summary>
    [HttpPost]
    [ProducesResponseType(StatusCodes.Status201Created, Type = typeof(ApiResult<OrderDto>))]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> Create([FromBody] CreateOrderDto request, CancellationToken cancellationToken)
    {
        var command = new CreateOrderCommand(request);
        var result = await mediator.Send(command, cancellationToken);
        return ApiResponse(result);
    }

    /// <summary>
    ///     Check if the customer has an order today
    /// </summary>
    [HttpGet("customer/{customerId}/today")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<OrderSummaryDto>))]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetTodayOrder(CustomerId customerId, CancellationToken cancellationToken)
    {
        var query = new GetTodayOrderByCustomerQuery(customerId);
        var order = await mediator.Send(query, cancellationToken);

        if (order == null)
            return NotFound<OrderSummaryDto>("Customer has no order today");

        return Ok(order, "Order found");
    }
}
