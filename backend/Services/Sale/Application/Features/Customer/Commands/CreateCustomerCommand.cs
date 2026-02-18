using MediatR;
using Sale.Application.Common.Attributes;
using Sale.Domain.Identifiers;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Customer.Commands;

/// <summary>
///     Command to create a new customer with digital signature support.
///     The CreatedByUserId is captured for non-repudiation, ensuring accountability
///     in customer creation operations.
///     
///     NOTE: This is a record to enable immutable data passing through MediatR pipeline.
///     The TransactionSigningBehavior will create a new command instance via "with" pattern
///     to attach the signature before passing to handler.
/// </summary>
public record CreateCustomerCommand(
    string FirstName,
    string LastName,
    string Address,
    string PhoneNumber,
    UserId CreatedByUserId) : IRequest<ApiResult<CustomerDto>>, IRequireDigitalSignature
{
    /// <summary>
    ///     Digital signature hash - attached by TransactionSigningBehavior after gRPC validation.
    ///     This property enables clean architecture: signature is attached BEFORE reaching the handler.
    /// </summary>
    public string? SignatureHash { get; init; }
}
