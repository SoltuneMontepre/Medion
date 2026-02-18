using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Security.Application.Abstractions;
using Security.Infrastructure.Data;
using Security.Infrastructure.Persistence.Repositories;

namespace Security.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services, IConfiguration config)
    {
        var connectionString = config.GetConnectionString("postgres-sale")
                               ?? "Host=localhost;Port=5432;Username=postgres;Password=postgres;Database=sale";

        services.AddDbContext<SecurityDbContext>(options =>
            options.UseNpgsql(connectionString, npgsqlOptions =>
                npgsqlOptions.MigrationsAssembly("Security.Infrastructure")));

        services.AddScoped<IUserDigitalSignatureRepository, UserDigitalSignatureRepository>();

        services.AddVaultClient(config);
        services.AddScoped<ISignatureService, HashiCorpSignatureService>();
        services.AddScoped<IVaultDigitalSignatureService, VaultDigitalSignatureService>();

        return services;
    }
}
