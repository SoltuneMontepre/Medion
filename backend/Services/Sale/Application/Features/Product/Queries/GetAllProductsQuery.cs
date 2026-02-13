using MediatR;
using Sale.Application.Common.DTOs;

namespace Sale.Application.Features.Product.Queries;

public class GetAllProductsQuery : IRequest<IReadOnlyList<ProductDto>>
{
}
