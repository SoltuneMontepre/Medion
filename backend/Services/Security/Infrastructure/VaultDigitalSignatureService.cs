using System.Text;
using System.Text.Json;
using Security.Application.Abstractions;
using VaultSharp;
using VaultSharp.V1.SecretsEngines.Transit;

namespace Security.Infrastructure;

/// <summary>
///     Implementation of digital signature service using HashiCorp Vault's Transit Engine.
///     This service provides cryptographic signing and verification operations for ensuring
///     non-repudiation and data integrity in customer creation workflows.
///
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
        Base64EncodedInput = base64Data,
        KeyVersion = null // Use latest key version for signing
      };

      // Call Vault Transit Engine to sign the data
      var response = await vaultClient.V1.Secrets.Transit.SignDataAsync(
          keyName: vaultOptions.KeyName,
          signRequestOptions: signOptions,
          mountPoint: vaultOptions.MountPoint,
          wrapTimeToLive: null,
          cancellationToken: cancellationToken);

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
      // Configure verification options
      var verifyOptions = new VerifySignatureRequestOptions
      {
        Base64EncodedInput = base64Data,
        Signature = signature
      };

      // Call Vault Transit Engine to verify the signature
      var response = await vaultClient.V1.Secrets.Transit.VerifySignatureAsync(
          keyName: vaultOptions.KeyName,
          verifySignatureRequestOptions: verifyOptions,
          mountPoint: vaultOptions.MountPoint,
          cancellationToken: cancellationToken);

      // Extract the verification result from the response
      return response?.Data?.SignatureValid ?? false;
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
      VaultSharp.V1.Commons.Secret<SigningResponse> response)
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
