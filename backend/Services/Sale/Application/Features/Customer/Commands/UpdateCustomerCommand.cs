using MediatR;
using Sale.Application.Common.DTOs;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Customer.Commands;

/// <summary>
///     Command to update an existing customer
/// </summary>
public class UpdateCustomerCommand : IRequest<ApiResult<CustomerDto>>
{
  public Guid Id { get; set; }
  public string FirstName { get; set; } = null!;
  public string LastName { get; set; } = null!;
  public string Address { get; set; } = null!;
  public string PhoneNumber { get; set; } = null!;
}
