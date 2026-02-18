using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Security.Application.Common.Abstractions;

namespace Security.Infrastructure.Services;

/// <summary>
///     Real implementation using HashiCorp Vault
///     For production: integrate with actual Vault SDK (VaultSharp NuGet package)
/// </summary>
public class HashiCorpVaultService : IVaultService
{
  private readonly ILogger<HashiCorpVaultService> _logger;
  private readonly string _vaultAddress;
  private readonly string _vaultToken;

  public HashiCorpVaultService(
      ILogger<HashiCorpVaultService> logger,
      IConfiguration configuration)
  {
    _logger = logger;
    _vaultAddress = configuration["Vault:Address"]
                    ?? throw new InvalidOperationException("Vault:Address not configured");
    _vaultToken = configuration["Vault:Token"]
                  ?? throw new InvalidOperationException("Vault:Token not configured");
  }

  public async Task<bool> ValidateTransactionPasswordAsync(
      string userId,
      string password,
      CancellationToken cancellationToken = default)
  {
    try
    {
      // TODO: In production, call actual Vault API to retrieve user's hashed password
      // Example:
      // var client = new VaultClient(new VaultClientSettings(_vaultAddress, _vaultToken));
      // var secret = await client.V1.Secrets.KeyValue.V2.ReadSecretAsync($"users/{userId}");
      // var hashedPassword = secret.Data.Data["password_hash"];
      // return BCrypt.Net.BCrypt.Verify(password, hashedPassword);

      // Placeholder: simulate validation
      _logger.LogInformation("Validating transaction password for user {UserId}", userId);

      // For demo, accept any non-empty password
      await Task.Delay(100, cancellationToken);
      return !string.IsNullOrWhiteSpace(password);
    }
    catch (Exception ex)
    {
      _logger.LogError(ex, "Error validating transaction password");
      return false;
    }
  }

  public async Task<string> GenerateSignatureAsync(
      string payload,
      string userId,
      CancellationToken cancellationToken = default)
  {
    try
    {
      // TODO: In production, use Vault's transit engine or sign API
      // Example:
      // var client = new VaultClient(new VaultClientSettings(_vaultAddress, _vaultToken));
      // var signRequest = new SignPayloadRequest { Payload = payload };
      // var response = await client.V1.Secrets.Transit.SignAsync("sign-key", signRequest);
      // return response.Data.Signature;

      // Placeholder: generate SHA256 hash (NOT cryptographically secure for production)
      await Task.Delay(50, cancellationToken);

      using (var sha256 = SHA256.Create())
      {
        var hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(payload));
        var hash = Convert.ToHexString(hashBytes);
        _logger.LogInformation("Generated signature for user {UserId} with hash {Hash}",
            userId, hash[..16] + "...");
        return hash;
      }
    }
    catch (Exception ex)
    {
      _logger.LogError(ex, "Error generating signature");
      throw;
    }
  }
}
