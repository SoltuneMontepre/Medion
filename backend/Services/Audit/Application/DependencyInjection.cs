using MediatR;
using Microsoft.Extensions.DependencyInjection;

namespace Audit.Application;

/// <summary>
///     Extension methods for registering Audit Service application layer services.
/// </summary>
public static class DependencyInjection
{
  public static IServiceCollection AddAuditApplicationServices(this IServiceCollection services)
  {
    // Register MediatR if needed for future use cases
    services.AddMediatR(cfg =>
    {
      cfg.RegisterServicesFromAssembly(typeof(DependencyInjection).Assembly);
    });

    return services;
  }
}
