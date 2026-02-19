using MediatR;
using Microsoft.AspNetCore.Mvc;
using Sale.Application.Common.DTOs;
using Sale.Application.Features.Product.Commands;
using Sale.Application.Features.Product.Queries;
using Sale.Domain.Identifiers.Id;
using ServiceDefaults.ApiResponses;

namespace Sale.API.Controllers;

/// <summary>
///     Product search controller
/// </summary>
[ApiController]
[Route("products")]
public class ProductController(IMediator mediator) : ApiControllerBase
{
    /// <summary>
    ///     Get all products
    /// </summary>
    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<IReadOnlyList<ProductDto>>))]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var query = new GetAllProductsQuery();
        var products = await mediator.Send(query, cancellationToken);
        return Ok(products, "Products retrieved successfully");
    }

    /// <summary>
    ///     Get product by ID
    /// </summary>
    [HttpGet("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<ProductDetailDto>))]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(ProductId id, CancellationToken cancellationToken)
    {
        var query = new GetProductByIdQuery(id);
        var product = await mediator.Send(query, cancellationToken);

        if (product == null)
            return NotFound<ProductDetailDto>($"Product with ID '{id}' not found");

        return Ok(product, "Product retrieved successfully");
    }

    /// <summary>
    ///     Search products by code or name
    /// </summary>
    [HttpGet("search")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<IReadOnlyList<ProductDto>>))]
    public async Task<IActionResult> Search([FromQuery] string term, [FromQuery] int? limit,
        CancellationToken cancellationToken)
    {
        var effectiveLimit = limit is > 0 and <= 50 ? limit.Value : 20;
        var query = new SearchProductsQuery(term, effectiveLimit);
        var products = await mediator.Send(query, cancellationToken);
        return Ok(products, "Products retrieved successfully");
    }

    /// <summary>
    ///     Create a new product
    /// </summary>
    [HttpPost]
    [ProducesResponseType(StatusCodes.Status201Created, Type = typeof(ApiResult<ProductDetailDto>))]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> Create([FromBody] CreateProductDto request, CancellationToken cancellationToken)
    {
        var command = new CreateProductCommand(request);
        var result = await mediator.Send(command, cancellationToken);
        return ApiResponse(result);
    }

    /// <summary>
    ///     Update an existing product
    /// </summary>
    [HttpPut("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<ProductDetailDto>))]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> Update(ProductId id, [FromBody] UpdateProductDto request,
        CancellationToken cancellationToken)
    {
        var command = new UpdateProductCommand
        {
            Id = id,
            Code = request.Code,
            Name = request.Name,
            Specification = request.Specification,
            Type = request.Type,
            Packaging = request.Packaging
        };

        var result = await mediator.Send(command, cancellationToken);
        return ApiResponse(result);
    }

    /// <summary>
    ///     Delete a product (soft delete)
    /// </summary>
    [HttpDelete("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ApiResult<bool>))]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(ProductId id, CancellationToken cancellationToken)
    {
        var command = new DeleteProductCommand(id);
        var result = await mediator.Send(command, cancellationToken);
        return ApiResponse(result);
    }
}
