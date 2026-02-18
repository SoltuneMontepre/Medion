namespace Security.Application.Common.Abstractions;

/// <summary>
///     Abstraction for HashiCorp Vault credential and signature operations
/// </summary>
public interface IVaultService
{
  /// <summary>
  ///     Validates a transaction password against Vault-stored credentials
  /// </summary>
  Task<bool> ValidateTransactionPasswordAsync(
      string userId,
      string password,
      CancellationToken cancellationToken = default);

  /// <summary>
  ///     Generates a digital signature using Vault-managed keys
  /// </summary>
  Task<string> GenerateSignatureAsync(
      string payload,
      string userId,
      CancellationToken cancellationToken = default);
}
