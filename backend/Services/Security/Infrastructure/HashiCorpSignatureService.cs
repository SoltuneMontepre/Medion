using System.Security.Cryptography;
using System.Text;
using Sale.Domain.Identifiers;
using Security.Application.Abstractions;
using VaultSharp;
using VaultSharp.V1.SecretsEngines.Transit;

namespace Security.Infrastructure;

public sealed class HashiCorpSignatureService(
    IUserDigitalSignatureRepository signatureRepository,
    IVaultClient vaultClient,
    VaultOptions vaultOptions) : ISignatureService
{
  private const int Iterations = 120_000;
  private const int HashSize = 32;
  private const string VaultSignaturePrefix = "vault:v1:";

  public async Task<bool> CheckPinAsync(UserId userId, string pin, CancellationToken cancellationToken = default)
  {
    var signature = await signatureRepository.GetByUserIdAsync(userId, cancellationToken);
    if (signature == null)
      return false;

    var computedHash = HashPin(pin, signature.PinSalt);
    return CryptographicOperations.FixedTimeEquals(computedHash, signature.PinHash);
  }

  public async Task<DigitalSignatureResult> VerifyAndSignAsync(UserId userId, string pin, string payload,
      CancellationToken cancellationToken = default)
  {
    var signature = await signatureRepository.GetByUserIdAsync(userId, cancellationToken)
                    ?? throw new InvalidOperationException("Digital signature profile was not found.");

    var computedHash = HashPin(pin, signature.PinSalt);
    if (!CryptographicOperations.FixedTimeEquals(computedHash, signature.PinHash))
      throw new UnauthorizedAccessException("PIN is invalid.");

    var payloadBase64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(payload));
    var signOptions = new SignRequestOptions
    {
      Base64EncodedInput = payloadBase64
    };

    var response = await vaultClient.V1.Secrets.Transit.SignDataAsync(
      vaultOptions.KeyName,
      signOptions,
      vaultOptions.MountPoint,
      wrapTimeToLive: null);

    var signatureBytes = ExtractSignatureBytes(response);
    return new DigitalSignatureResult(signatureBytes, signature.PublicKey);
  }

  private static byte[] HashPin(string pin, byte[] salt)
  {
    return Rfc2898DeriveBytes.Pbkdf2(pin, salt, Iterations, HashAlgorithmName.SHA256, HashSize);
  }

  private static byte[] ExtractSignatureBytes(VaultSharp.V1.Commons.Secret<SigningResponse> response)
  {
    var signature = response?.Data?.Signature;
    if (string.IsNullOrWhiteSpace(signature))
      throw new InvalidOperationException("Vault returned an empty signature.");

    if (!signature.StartsWith(VaultSignaturePrefix, StringComparison.Ordinal))
      throw new InvalidOperationException("Vault signature format is invalid.");

    var base64Signature = signature[VaultSignaturePrefix.Length..];
    return Convert.FromBase64String(base64Signature);
  }
}
