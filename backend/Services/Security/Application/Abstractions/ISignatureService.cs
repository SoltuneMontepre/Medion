namespace Security.Application.Abstractions;

public interface ISignatureService
{
    Task<bool> CheckPinAsync(Guid userId, string pin, CancellationToken cancellationToken = default);

    Task<DigitalSignatureResult> VerifyAndSignAsync(Guid userId, string pin, string payload,
        CancellationToken cancellationToken = default);
}

public sealed record DigitalSignatureResult(byte[] Signature, string PublicKey);
