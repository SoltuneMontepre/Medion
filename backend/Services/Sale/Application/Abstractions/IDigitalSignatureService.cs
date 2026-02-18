using Sale.Domain.Identifiers;

namespace Sale.Application.Abstractions;

public interface IDigitalSignatureService
{
    Task<bool> VerifyPinAsync(UserId userId, string pin, CancellationToken cancellationToken = default);
    Task<DigitalSignatureResult> SignAsync(UserId userId, string payload, string pin,
        CancellationToken cancellationToken = default);
}

public sealed record DigitalSignatureResult(byte[] Signature, string PublicKey);

public enum DigitalSignatureFailure
{
    InvalidPin,
    InvalidArgument,
    Internal,
    Unavailable
}

public sealed class DigitalSignatureException(DigitalSignatureFailure failure, string message, Exception? inner = null)
    : Exception(message, inner)
{
    public DigitalSignatureFailure Failure { get; } = failure;
}
