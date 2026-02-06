using MediatR;
using Microsoft.AspNetCore.Mvc;
using Sale.Application.Common.DTOs;
using Sale.Application.Features.Customer.Commands;
using Sale.Application.Features.Customer.Queries;
using ServiceDefaults.ApiResponses;

namespace Sale.API.Controllers;

/// <summary>
///     Customer management controller
///     Handles CRUD operations for customers
/// </summary>
[ApiController]
[Route("[controller]")]
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
    ///     Get customer by ID
    /// </summary>
    [HttpGet("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<CustomerDto>))]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
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
        var command = new CreateCustomerCommand(request);
        var result = await mediator.Send(command, cancellationToken);

        if (result.IsSuccess && result.Data != null)
            return Created(nameof(GetById), new { id = result.Data.Id }, result.Data, result.Message);

        return BadRequest<CustomerDto>("Customer creation failed");
    }

    /// <summary>
    ///     Update an existing customer
    /// </summary>
    [HttpPut("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<CustomerDto>))]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateCustomerDto request, CancellationToken cancellationToken)
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
    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<bool>))]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(Guid id, CancellationToken cancellationToken)
    {
        var command = new DeleteCustomerCommand(id);
        var result = await mediator.Send(command, cancellationToken);
        return ApiResponse(result);
    }
}
