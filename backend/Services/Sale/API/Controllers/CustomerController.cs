using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Sale.Application.Common.DTOs;
using Sale.Application.Features.Customer.Commands;
using Sale.Application.Features.Customer.Queries;
using Sale.Domain.Identifiers;
using ServiceDefaults.ApiResponses;

namespace Sale.API.Controllers;

/// <summary>
///     Customer management controller
///     Handles CRUD operations for customers
/// </summary>
[ApiController]
[Route("customers")]
public class CustomerController(IMediator mediator) : ApiControllerBase
{
    /// <summary>
    ///     Get all customers
    /// </summary>
    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<IEnumerable<CustomerDto>>))]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var query = new GetAllCustomersQuery();
        var customers = await mediator.Send(query, cancellationToken);
        return Ok(customers, "Customers retrieved successfully");
    }

    /// <summary>
    ///     Search customers by code, name, or phone
    /// </summary>
    [HttpGet("search")]
    [Authorize(Roles = "Sale Admin")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<IReadOnlyList<CustomerDto>>))]
    public async Task<IActionResult> Search([FromQuery] string term, [FromQuery] int? limit,
        CancellationToken cancellationToken)
    {
        var effectiveLimit = limit is > 0 and <= 50 ? limit.Value : 20;
        var query = new SearchCustomersQuery(term, effectiveLimit);
        var customers = await mediator.Send(query, cancellationToken);
        return Ok(customers, "Customers retrieved successfully");
    }

    /// <summary>
    ///     Get customer by ID
    /// </summary>
    [HttpGet("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<CustomerDto>))]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(CustomerId id, CancellationToken cancellationToken)
    {
        var query = new GetCustomerByIdQuery(id);
        var customer = await mediator.Send(query, cancellationToken);

        if (customer == null)
            return NotFound<CustomerDto>($"Customer with ID '{id}' not found");

        return Ok(customer, "Customer retrieved successfully");
    }

    /// <summary>
    ///     Create a new customer
    /// </summary>
    [HttpPost]
    [ProducesResponseType(StatusCodes.Status201Created, Type = typeof(ApiResult<CustomerDto>))]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Create([FromBody] CreateCustomerDto request, CancellationToken cancellationToken)
    {
        // Extract the authenticated user ID from the current principal
        var userId = User.FindFirst("sub")?.Value
                    ?? User.FindFirst("sid")?.Value
                    ?? User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
                    ?? throw new InvalidOperationException("User ID not found in token claims. Ensure Keycloak is configured to include 'sub' claim.");

        var command = new CreateCustomerCommand(request, new UserId(Guid.Parse(userId)));
        var result = await mediator.Send(command, cancellationToken);

        if (result.IsSuccess && result.Data != null)
            return Created(nameof(GetById), new { id = result.Data.Id }, result.Data, result.Message);

        return BadRequest<CustomerDto>(result.Message ?? "Customer creation failed", result.Errors);
    }

    /// <summary>
    ///     Update an existing customer
    /// </summary>
    [HttpPut("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<CustomerDto>))]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Update(CustomerId id, [FromBody] UpdateCustomerDto request, CancellationToken cancellationToken)
    {
        var command = new UpdateCustomerCommand
        {
            Id = id,
            FirstName = request.FirstName,
            LastName = request.LastName,
            Address = request.Address,
            PhoneNumber = request.PhoneNumber
        };

        var result = await mediator.Send(command, cancellationToken);
        return ApiResponse(result);
    }

    /// <summary>
    ///     Delete a customer (soft delete)
    /// </summary>
    [HttpDelete("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<bool>))]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(CustomerId id, CancellationToken cancellationToken)
    {
        var command = new DeleteCustomerCommand(id);
        var result = await mediator.Send(command, cancellationToken);
        return ApiResponse(result);
    }
}
