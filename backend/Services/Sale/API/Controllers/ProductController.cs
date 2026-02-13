using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Sale.Application.Common.DTOs;
using Sale.Application.Features.Product.Queries;
using ServiceDefaults.ApiResponses;

namespace Sale.API.Controllers;

/// <summary>
///     Product search controller
/// </summary>
[ApiController]
[Route("products")]
[Authorize(Roles = "Sale Admin")]
public class ProductController(IMediator mediator) : ApiControllerBase
{
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
}
