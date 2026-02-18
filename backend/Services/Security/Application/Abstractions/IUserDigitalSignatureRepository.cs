namespace Security.Application.Abstractions;

// Note: This interface is for legacy PIN-based signing
// Current implementation uses gRPC-based transaction signing
// UserDigitalSignature entity should be created in Security.Domain if this is needed
public interface IUserDigitalSignatureRepository
{
    // Placeholder - needs proper Security.Domain.UserDigitalSignature entity
    // Task<UserDigitalSignature?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
    // Task AddOrUpdateAsync(UserDigitalSignature signature, CancellationToken cancellationToken = default);
}
