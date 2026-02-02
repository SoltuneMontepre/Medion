using Identity.Application.Common.Mappings;
using Identity.Application.Features.Auth.Commands;
using Mapster;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;

namespace Identity.Application;

/// <summary>
///     Extension methods for registering Application layer services
/// </summary>
public static class DependencyInjection
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        // Register MediatR
        services.AddMediatR(cfg => { cfg.RegisterServicesFromAssembly(typeof(RegisterUserCommand).Assembly); });

        // Register Mapster
        var typeAdapterConfig = new TypeAdapterConfig();
        typeAdapterConfig.Apply(new MappingConfig());
        services.AddSingleton(typeAdapterConfig);
        services.AddScoped<IMapper, ServiceMapper>();

        return services;
    }
}
