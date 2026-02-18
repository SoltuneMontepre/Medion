using MediatR;
using Sale.Application.Common.Attributes;
using Sale.Application.Common.DTOs;
using Sale.Domain.Identifiers;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Customer.Commands;

/// <summary>
///     Command to create a new customer with digital signature support.
///     The CreatedByUserId is captured for non-repudiation, ensuring accountability
///     in customer creation operations.
///     NOTE: This record is PURE APPLICATION LOGIC - it does NOT reference HTTP or Infrastructure.
///     Signature is retrieved from scoped TransactionContext, not from this command.
/// </summary>
public record CreateCustomerCommand(
    string FirstName,
    string LastName,
    string Address,
    string PhoneNumber,
    UserId CreatedByUserId) : IRequest<ApiResult<CustomerDto>>, IRequireDigitalSignature;
