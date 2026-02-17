using Medion.Security.Contracts;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Sale.Application.Abstractions;
using Sale.Infrastructure.Data;
using Sale.Infrastructure.Persistence.Repositories;

namespace Sale.Infrastructure;

/// <summary>
///     Extension methods for registering Infrastructure layer services.
///     Note: Vault client has been moved to the Audit Service.
///     This service now focuses solely on customer domain operations.
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

        var securityServiceUrl = config["SecurityService:GrpcUrl"] ?? "http://security-api";
        services.AddGrpcClient<SignatureService.SignatureServiceClient>(options =>
        {
            options.Address = new Uri(securityServiceUrl);
        });

        services.AddScoped<IDigitalSignatureService, GrpcDigitalSignatureService>();

        return services;
    }
}


