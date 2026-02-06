using MediatR;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Customer.Commands;

/// <summary>
///     Command to delete a customer (soft delete)
/// </summary>
public class DeleteCustomerCommand(Guid id) : IRequest<ApiResult<bool>>
{
  public Guid Id { get; set; } = id;
}
