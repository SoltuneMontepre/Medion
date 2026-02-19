using Sale.Domain.Entities;
using Sale.Domain.Identifiers;
using Sale.Domain.Identifiers.Id;

namespace Sale.Application.Abstractions;

/// <summary>
///     Repository interface for managing customer signature records.
///     Handles persistence and retrieval of digital signatures associated with customer creation operations.
/// </summary>
public interface ICustomerSignatureRepository : IBaseRepository<CustomerSignature, CustomerSignatureId>
{
    /// <summary>
    ///     Retrieves the signature associated with a specific customer.
    /// </summary>
    /// <param name="customerId">The ID of the customer.</param>
    /// <param name="cancellationToken">Cancellation token for async operation.</param>
    /// <returns>The customer signature if found; otherwise, null.</returns>
    Task<CustomerSignature?> GetByCustomerIdAsync(CustomerId customerId, CancellationToken cancellationToken = default);

    /// <summary>
    ///     Retrieves all signatures created by a specific user.
    ///     Useful for audit trails and compliance verification.
    /// </summary>
    /// <param name="userId">The ID of the user who created the signatures.</param>
    /// <param name="cancellationToken">Cancellation token for async operation.</param>
    /// <returns>A collection of customer signatures created by the user.</returns>
    Task<IEnumerable<CustomerSignature>> GetByUserIdAsync(UserId userId, CancellationToken cancellationToken = default);

    /// <summary>
    ///     Retrieves signatures within a specific date range.
    ///     Useful for audit reports and compliance verification.
    /// </summary>
    /// <param name="startDate">The start date (inclusive).</param>
    /// <param name="endDate">The end date (inclusive).</param>
    /// <param name="cancellationToken">Cancellation token for async operation.</param>
    /// <returns>A collection of customer signatures within the date range.</returns>
    Task<IEnumerable<CustomerSignature>> GetByDateRangeAsync(
        DateTime startDate,
        DateTime endDate,
        CancellationToken cancellationToken = default);

    /// <summary>
    ///     Marks a signature as verified against Vault.
    /// </summary>
    /// <param name="id">The ID of the signature to verify.</param>
    /// <param name="cancellationToken">Cancellation token for async operation.</param>
    Task MarkAsVerifiedAsync(CustomerSignatureId id, CancellationToken cancellationToken = default);
}
