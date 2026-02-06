using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Sale.Domain.Repositories;
using Sale.Infrastructure.Persistence.Repositories;

namespace Sale.Infrastructure;

/// <summary>
///     Extension methods for registering Infrastructure layer services
/// </summary>
public static class DependencyInjection
{
  public static IServiceCollection AddInfrastructureServices(this IServiceCollection services)
  {
    // Register repositories
    services.AddScoped<ICustomerRepository, CustomerRepository>();

    return services;
  }
}
