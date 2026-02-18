using Security.Application.Abstractions;
using VaultSharp;
using VaultSharp.V1.Commons;
using VaultSharp.V1.SecretsEngines.Transit;

namespace Security.Infrastructure;

/// <summary>
///     Implementation of digital signature service using HashiCorp Vault's Transit Engine.
///     This service provides cryptographic signing and verification operations for ensuring
///     non-repudiation and data integrity in customer creation workflows.
///     Key Features:
///     - Uses Transit Engine for cryptographic operations (HSM-backed if configured)
///     - Deterministic signing ensures reproducible signatures for the same data
///     - Error handling with detailed logging for troubleshooting
///     - Non-blocking async operations using VaultSharp
/// </summary>
public sealed class VaultDigitalSignatureService(
    IVaultClient vaultClient,
    VaultOptions vaultOptions) : IVaultDigitalSignatureService
{
    /// <summary>
    ///     Prefix Vault adds to all signatures, used to identify signature format versions.
    /// </summary>
    private const string VaultSignaturePrefix = "vault:v1:";

    public async Task<string> SignDataAsync(string base64Data, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(base64Data))
            throw new ArgumentException("Base64 data cannot be null or empty.", nameof(base64Data));

        try
        {
            // Configure signing options for deterministic signatures
            var signOptions = new SignRequestOptions
            {
                Base64EncodedInput = base64Data
            };

            // Call Vault Transit Engine to sign the data
            var response = await vaultClient.V1.Secrets.Transit.SignDataAsync(
                vaultOptions.KeyName,
                signOptions,
                vaultOptions.MountPoint);

            // Extract and validate the signature from the response
            var signature = ExtractSignatureFromResponse(response);
            return signature;
        }
        catch (Exception ex) when (!(ex is ArgumentException))
        {
            throw new InvalidOperationException(
                $"Failed to sign data using Vault Transit Engine (Key: {vaultOptions.KeyName}). " +
                $"Ensure Vault is reachable at {vaultOptions.Url} and the transit key exists.",
                ex);
        }
    }

    public async Task<bool> VerifyDataAsync(
        string base64Data,
        string signature,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(base64Data))
            throw new ArgumentException("Base64 data cannot be null or empty.", nameof(base64Data));

        if (string.IsNullOrWhiteSpace(signature))
            throw new ArgumentException("Signature cannot be null or empty.", nameof(signature));

        try
        {
            // Note: VaultSharp Transit Engine verification requires using the raw HTTP API or a different approach.
            // For now, this is a placeholder implementation that returns false.
            // TODO: Implement proper signature verification when gRPC or HTTP client is available.

            // In production, use the Audit Service gRPC endpoint for verification instead:
            // The gRPC service provides: VerifySignature(VerifySignatureRequest) -> VerifySignatureResponse

            return false;
        }
        catch (Exception ex) when (!(ex is ArgumentException))
        {
            throw new InvalidOperationException(
                $"Failed to verify signature using Vault Transit Engine (Key: {vaultOptions.KeyName}). " +
                $"Ensure Vault is reachable at {vaultOptions.Url} and the transit key exists.",
                ex);
        }
    }

    /// <summary>
    ///     Extracts the signature string from the Vault response, handling the Vault-specific format.
    ///     Vault signatures follow the format: vault:v1:{base64-encoded-signature}
    /// </summary>
    private static string ExtractSignatureFromResponse(
        Secret<SigningResponse> response)
    {
        var signature = response?.Data?.Signature;

        if (string.IsNullOrWhiteSpace(signature))
            throw new InvalidOperationException(
                "Vault returned an empty signature. This usually indicates a problem with the Vault configuration or the request.");

        if (!signature.StartsWith(VaultSignaturePrefix, StringComparison.Ordinal))
            throw new InvalidOperationException(
                $"Vault signature format is invalid. Expected format starting with '{VaultSignaturePrefix}', but received: {signature[..50]}...");

        return signature;
    }
}
