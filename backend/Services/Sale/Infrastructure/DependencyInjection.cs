using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Sale.Application.Abstractions;
using Sale.Domain.Repositories;
using Sale.Infrastructure.Data;
using Sale.Infrastructure.Persistence.Repositories;

namespace Sale.Infrastructure;

/// <summary>
///     Extension methods for registering Infrastructure layer services
/// </summary>
public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services, IConfiguration config)
    {
        var connectionString = config.GetConnectionString("postgres-sale")
                               ?? "Host=localhost;Port=5432;Username=postgres;Password=postgres;Database=sale";

        services.AddDbContext<SaleDbContext>(options =>
            options.UseNpgsql(connectionString, npgsqlOptions =>
                npgsqlOptions.MigrationsAssembly("Sale.Infrastructure")));

        // Register repositories
        services.AddScoped<ICustomerRepository, CustomerRepository>();
        services.AddScoped<IOrderRepository, OrderRepository>();
        services.AddScoped<IProductRepository, ProductRepository>();
        services.AddScoped<IUserDigitalSignatureRepository, UserDigitalSignatureRepository>();

        // Digital signature service (Vault integration will replace this)
        services.AddScoped<IDigitalSignatureService, DigitalSignatureService>();

        return services;
    }
}
