// using Medion.Security.Contracts; // LEGACY: Old proto namespace, removed

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Sale.Application.Abstractions;
using Sale.Infrastructure.Persistence;
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
        var connectionString = config.GetConnectionString("postgresSale")
                               ?? throw new InvalidOperationException("Connection string 'postgresSale' not found. Ensure it's provided by Aspire or set in configuration.");

        services.AddDbContext<SaleDbContext>(options =>
        {
            options.UseNpgsql(connectionString, npgsqlOptions =>
                npgsqlOptions.MigrationsAssembly("Sale.Infrastructure"));

            // Suppress pending model changes warning in Development
            // TODO: Generate proper migration before production deployment
            options.ConfigureWarnings(warnings =>
                warnings.Ignore(RelationalEventId.PendingModelChangesWarning));
        });

        // Register repositories
        services.AddScoped<ICustomerRepository, CustomerRepository>();
        services.AddScoped<IOrderRepository, OrderRepository>();
        services.AddScoped<IProductRepository, ProductRepository>();
        services.AddScoped<IUserDigitalSignatureRepository, UserDigitalSignatureRepository>();

        // LEGACY: PIN-based signing via gRPC - commented out pending migration to transaction password signing
        // TODO: Migrate Order signing to use TransactionSigningBehavior with transaction passwords
        // var securityServiceUrl = config["SecurityService:GrpcUrl"] ?? "http://security-api";
        // services.AddGrpcClient<SignatureService.SignatureServiceClient>(options =>
        // {
        //     options.Address = new Uri(securityServiceUrl);
        // });
        // services.AddScoped<IDigitalSignatureService, GrpcDigitalSignatureService>();

        return services;
    }
}
