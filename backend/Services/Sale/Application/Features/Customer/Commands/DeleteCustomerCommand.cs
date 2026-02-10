using MediatR;
using Sale.Domain.Identifiers;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Customer.Commands;

/// <summary>
///     Command to delete a customer (soft delete)
/// </summary>
public class DeleteCustomerCommand(CustomerId id) : IRequest<ApiResult<bool>>
{
    public CustomerId Id { get; set; } = id;
}
