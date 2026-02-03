using Identity.Application.Common.Abstractions;
using Microsoft.Extensions.Caching.Memory;

namespace Identity.Infrastructure.Services;

/// <summary>
///     Implementation of token blacklist service using IMemoryCache
///     Stores revoked tokens in memory until they expire
/// </summary>
public class TokenBlacklistService : ITokenBlacklistService
{
    private readonly IMemoryCache _cache;
    private const string BlacklistPrefix = "blacklist_";

    public TokenBlacklistService(IMemoryCache cache)
    {
        _cache = cache;
    }

    public Task AddToBlacklistAsync(string token, DateTimeOffset expiryDate)
    {
        var cacheKey = GetCacheKey(token);
        
        // Store token in cache with absolute expiration matching token expiry
        var cacheOptions = new MemoryCacheEntryOptions
        {
            AbsoluteExpiration = expiryDate,
            Priority = CacheItemPriority.High
        };

        _cache.Set(cacheKey, true, cacheOptions);
        
        return Task.CompletedTask;
    }

    public Task<bool> IsBlacklistedAsync(string token)
    {
        var cacheKey = GetCacheKey(token);
        var isBlacklisted = _cache.TryGetValue(cacheKey, out _);
        
        return Task.FromResult(isBlacklisted);
    }

    private static string GetCacheKey(string token)
    {
        // Use a hash of the token to save memory (tokens can be long)
        // In production, consider using a proper hash like SHA256
        return $"{BlacklistPrefix}{token.GetHashCode()}";
    }
}
