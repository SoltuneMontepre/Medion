using System.Security.Cryptography;
using Security.Application.Abstractions;
using VaultSharp;
using VaultSharp.V1.Commons;
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

    public async Task<bool> CheckPinAsync(Guid userId, string pin, CancellationToken cancellationToken = default)
    {
        // Implementation disabled - needs Security.Domain.UserDigitalSignature entity
        throw new NotImplementedException("PIN-based signing not implemented. Use gRPC transaction signing.");
    }

    public async Task<DigitalSignatureResult> VerifyAndSignAsync(Guid userId, string pin, string payload,
        CancellationToken cancellationToken = default)
    {
        // Implementation disabled - needs Security.Domain.UserDigitalSignature entity
        throw new NotImplementedException("PIN-based signing not implemented. Use gRPC transaction signing.");
    }

    private static byte[] HashPin(string pin, byte[] salt)
    {
        return Rfc2898DeriveBytes.Pbkdf2(pin, salt, Iterations, HashAlgorithmName.SHA256, HashSize);
    }

    private static byte[] ExtractSignatureBytes(Secret<SigningResponse> response)
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
