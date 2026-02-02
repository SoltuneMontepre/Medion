using Identity.Domain.Entities;

namespace Identity.Application.Common.Abstractions;

public interface ITokenService
{
    Task<string> GenerateTokenAsync(User user, CancellationToken cancellationToken = default);
    Task<string> GenerateRefreshTokenAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<bool> ValidateTokenAsync(string token, CancellationToken cancellationToken = default);
}
