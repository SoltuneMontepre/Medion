using MediatR;
using Sale.Application.Common.DTOs;
using Sale.Domain.Identifiers;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Customer.Commands;

/// <summary>
///     Command to create a new customer.
///     CreatedByUserId is captured for audit/accountability.
/// </summary>
public record CreateCustomerCommand(
    string FirstName,
    string LastName,
    string Address,
    string PhoneNumber,
    UserId CreatedByUserId) : IRequest<ApiResult<CustomerDto>>;
