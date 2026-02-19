namespace Security.Application.Abstractions;

/// <summary>
///     Service for managing digital signatures using HashiCorp Vault's Transit Engine.
///     Provides cryptographic signing and verification capabilities for ensuring non-repudiation
///     and data integrity in customer creation workflows.
/// </summary>
public interface IVaultDigitalSignatureService
{
    /// <summary>
    ///     Signs a base64-encoded payload using Vault's Transit Engine.
    /// </summary>
    /// <param name="base64Data">The base64-encoded data to sign.</param>
    /// <param name="cancellationToken">Cancellation token for async operation.</param>
    /// <returns>A base64-encoded signature.</returns>
    /// <exception cref="InvalidOperationException">Thrown when Vault returns an invalid response.</exception>
    /// <exception cref="VaultApiException">Thrown when Vault API call fails.</exception>
    Task<string> SignDataAsync(string base64Data, CancellationToken cancellationToken = default);

    /// <summary>
    ///     Verifies a digital signature against the original base64-encoded data using Vault's Transit Engine.
    /// </summary>
    /// <param name="base64Data">The base64-encoded original data.</param>
    /// <param name="signature">The base64-encoded signature to verify.</param>
    /// <param name="cancellationToken">Cancellation token for async operation.</param>
    /// <returns>True if the signature is valid; otherwise, false.</returns>
    /// <exception cref="InvalidOperationException">Thrown when Vault returns an invalid response.</exception>
    /// <exception cref="VaultApiException">Thrown when Vault API call fails.</exception>
    Task<bool> VerifyDataAsync(string base64Data, string signature, CancellationToken cancellationToken = default);
}

/// <summary>
///     Represents the result of a digital signature operation.
/// </summary>
public sealed record DigitalSignaturePayload(
    string CustomerId,
    string CustomerData,
    string CreatedByUserId,
    DateTime SignedAt);

/// <summary>
///     Strongly typed Id for customer signatures.
/// </summary>
public sealed record CustomerSignatureId(Guid Value);
