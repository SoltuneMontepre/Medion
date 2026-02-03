namespace Identity.Application.Common.Abstractions;

/// <summary>
///     Service for managing token blacklist (revoked tokens)
///     Uses IMemoryCache to store invalidated tokens until they expire
/// </summary>
public interface ITokenBlacklistService
{
  /// <summary>
  ///     Add a token to the blacklist
  /// </summary>
  /// <param name="token">JWT token to blacklist</param>
  /// <param name="expiryDate">Token expiration date (cache will auto-remove after this)</param>
  Task AddToBlacklistAsync(string token, DateTimeOffset expiryDate);

  /// <summary>
  ///     Check if a token is blacklisted
  /// </summary>
  /// <param name="token">JWT token to check</param>
  /// <returns>True if token is blacklisted, false otherwise</returns>
  Task<bool> IsBlacklistedAsync(string token);
}
