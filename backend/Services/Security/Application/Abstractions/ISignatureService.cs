using Sale.Domain.Identifiers;

namespace Security.Application.Abstractions;

public interface ISignatureService
{
  Task<bool> CheckPinAsync(UserId userId, string pin, CancellationToken cancellationToken = default);
  Task<DigitalSignatureResult> VerifyAndSignAsync(UserId userId, string pin, string payload,
      CancellationToken cancellationToken = default);
}

public sealed record DigitalSignatureResult(byte[] Signature, string PublicKey);
