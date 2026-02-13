using System.Security.Cryptography;
using System.Text;
using Sale.Application.Abstractions;
using Sale.Domain.Identifiers;

namespace Sale.Infrastructure;

public sealed class DigitalSignatureService(IUserDigitalSignatureRepository signatureRepository) : IDigitalSignatureService
{
    private const int Iterations = 120_000;
    private const int HashSize = 32;

    public async Task<bool> VerifyPinAsync(UserId userId, string pin, CancellationToken cancellationToken = default)
    {
        var signature = await signatureRepository.GetByUserIdAsync(userId, cancellationToken);
        if (signature == null)
            return false;

        var computedHash = HashPin(pin, signature.PinSalt);
        return CryptographicOperations.FixedTimeEquals(computedHash, signature.PinHash);
    }

    public async Task<DigitalSignatureResult> SignAsync(UserId userId, string payload,
        CancellationToken cancellationToken = default)
    {
        var signature = await signatureRepository.GetByUserIdAsync(userId, cancellationToken) ?? throw new InvalidOperationException("Digital signature profile was not found.");
        var payloadBytes = Encoding.UTF8.GetBytes(payload);

        // Mock signing: use a derived key as a stand-in for a Vault private key.
        using var hmac = new HMACSHA256(signature.PinHash);
        var signedBytes = hmac.ComputeHash(payloadBytes);

        return new DigitalSignatureResult(signedBytes, signature.PublicKey);
    }

    private static byte[] HashPin(string pin, byte[] salt)
    {
        return Rfc2898DeriveBytes.Pbkdf2(pin, salt, Iterations, HashAlgorithmName.SHA256, HashSize);
    }
}
