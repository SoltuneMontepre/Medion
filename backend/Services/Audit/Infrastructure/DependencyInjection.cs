using Audit.Application.Abstractions;
using Audit.Infrastructure.Data;
using Audit.Infrastructure.Persistence.Repositories;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Security.Infrastructure;

namespace Audit.Infrastructure;

/// <summary>
///     Extension methods for registering Audit Service infrastructure layer services.
///     Configures:
///     - Database context
///     - Repositories
///     - Vault client for digital signatures
///     - MassTransit consumers for event handling
/// </summary>
public static class DependencyInjection
{
  public static IServiceCollection AddAuditInfrastructureServices(
      this IServiceCollection services,
      IConfiguration config)
  {
    // Database configuration
    var connectionString = config.GetConnectionString("postgres-audit")
                           ?? "Host=localhost;Port=5432;Username=postgres;Password=postgres;Database=audit";

    services.AddDbContext<AuditDbContext>(options =>
        options.UseNpgsql(connectionString, npgsqlOptions =>
            npgsqlOptions.MigrationsAssembly("Audit.Infrastructure")));

    // Repository registration
    services.AddScoped<IGlobalAuditLogRepository, GlobalAuditLogRepository>();

    // Vault configuration for digital signatures
    services.AddVaultClient(config);

    return services;
  }

  /// <summary>
  ///     Configures MassTransit with RabbitMQ for event consumption.
  ///     Registers the CustomerCreatedAuditConsumer.
  /// </summary>
  public static void AddAuditEventConsumers(this IBusRegistrationConfigurator cfg)
  {
    cfg.AddConsumer<Audit.Application.IntegrationEvents.Consumers.CustomerCreatedAuditConsumer>()
        .Endpoint(e =>
        {
          // Configure queue name for the consumer
          e.Name = "audit-customer-created";
          e.InstanceId = "audit-01";
        });
  }
}
