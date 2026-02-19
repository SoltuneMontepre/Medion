using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Security.Application.Abstractions;
using Security.Application.Common.Abstractions;
using Security.Application.Features.Signature.Commands;
using Security.Infrastructure.Data;
using Security.Infrastructure.Persistence.Repositories;
using Security.Infrastructure.Services;

namespace Security.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services, IConfiguration config)
    {
        var connectionString = config.GetConnectionString("postgres_security")
                               ?? "Host=localhost;Port=5432;Username=postgres;Password=postgres;Database=security";

        services.AddDbContext<SecurityDbContext>(options =>
            options.UseNpgsql(connectionString, npgsqlOptions =>
                npgsqlOptions.MigrationsAssembly("Security.Infrastructure")));

        services.AddScoped<IUserDigitalSignatureRepository, UserDigitalSignatureRepository>();
        services.AddScoped<IUserSecurityProfileRepository, UserSecurityProfileRepository>();
        services.AddScoped<ISignatureRepository, SignatureRepository>();

        services.AddVaultClient(config);
        services.AddScoped<ISignatureService, HashiCorpSignatureService>();
        services.AddScoped<IVaultDigitalSignatureService, VaultDigitalSignatureService>();
        services.AddScoped<IVaultService, HashiCorpVaultService>();

        return services;
    }
}
