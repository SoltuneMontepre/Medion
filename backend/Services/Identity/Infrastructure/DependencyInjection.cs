using Identity.Application.Common.Abstractions;
using Identity.Domain.Repositories;
using Identity.Infrastructure.Persistence.Repositories;
using Identity.Infrastructure.Services;
using IdentityDbContext = Identity.Infrastructure.Persistence.IdentityDbContext;

namespace Identity.Infrastructure;

/// <summary>
///     Extension methods for registering Infrastructure layer services
/// </summary>
public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructureServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // Register DbContext
        var connectionString = configuration.GetConnectionString("DefaultConnection")
                               ?? throw new InvalidOperationException(
                                   "Connection string 'DefaultConnection' not found.");

        services.AddDbContext<IdentityDbContext>(options =>
            options.UseNpgsql(connectionString, npgsqlOptions =>
                npgsqlOptions.MigrationsAssembly("Services.Identity.Infrastructure")));

        // Register repositories
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IRoleRepository, RoleRepository>();

        // Register JWT service
        var jwtSettings = configuration.GetSection("JwtSettings").Get<JwtSettings>()
                          ?? throw new InvalidOperationException("JwtSettings configuration is missing");
        services.AddSingleton(jwtSettings);
        services.AddScoped<ITokenService, JwtTokenService>();

        // Register Memory Cache
        services.AddMemoryCache();

        // Register Token Blacklist Service
        services.AddSingleton<ITokenBlacklistService, TokenBlacklistService>();

        return services;
    }
}
