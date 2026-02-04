using Identity.Application.Common.Behaviors;
using Identity.Application.Common.Mappings;
using Identity.Application.Features.Auth.Commands;

namespace Identity.Application;

/// <summary>
///     Extension methods for registering Application layer services
/// </summary>
public static class DependencyInjection
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        // Register FluentValidation
        services.AddValidatorsFromAssembly(typeof(RegisterUserCommand).Assembly);

        // Register MediatR with Validation Pipeline Behavior
        services.AddMediatR(cfg =>
        {
            cfg.RegisterServicesFromAssembly(typeof(RegisterUserCommand).Assembly);
            cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        });

        // Register Mapster
        var typeAdapterConfig = new TypeAdapterConfig();
        typeAdapterConfig.Apply(new MappingConfig());
        services.AddSingleton(typeAdapterConfig);
        services.AddScoped<IMapper, ServiceMapper>();

        return services;
    }
}
