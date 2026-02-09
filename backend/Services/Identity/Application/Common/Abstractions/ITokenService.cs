using Identity.Domain.Entities;
using Identity.Domain.Identifiers;

namespace Identity.Application.Common.Abstractions;

public interface ITokenService
{
    Task<string> GenerateTokenAsync(User user, CancellationToken cancellationToken = default);
    Task<string> GenerateRefreshTokenAsync(IdentityId userId, CancellationToken cancellationToken = default);
    Task<bool> ValidateTokenAsync(string token, CancellationToken cancellationToken = default);
}
