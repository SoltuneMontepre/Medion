using FluentValidation;
using Mapster;
using MapsterMapper;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using Sale.Application.Common.Behaviors;
using Sale.Application.Common.Mappings;
using Sale.Application.Features.Customer.Commands;

namespace Sale.Application;

/// <summary>
///     Extension methods for registering Application layer services
/// </summary>
public static class DependencyInjection
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        // Register FluentValidation
        services.AddValidatorsFromAssembly(typeof(CreateCustomerCommand).Assembly);

        // Register MediatR with Pipeline Behaviors
        // Order matters: Signing -> Validation -> Handler -> Audit Logging
        // Note: TransactionSigningBehavior moved to Sale.API layer (needs gRPC client types)
        services.AddMediatR(cfg =>
        {
            cfg.RegisterServicesFromAssembly(typeof(CreateCustomerCommand).Assembly);
            // TransactionSigningBehavior registered in Sale.API Program.cs
            cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
            cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(AuditLoggingBehavior<,>));
        });

        // Register Mapster
        var typeAdapterConfig = new TypeAdapterConfig();
        typeAdapterConfig.Apply(new MappingConfig());
        services.AddSingleton(typeAdapterConfig);
        services.AddScoped<IMapper, ServiceMapper>();

        return services;
    }
}
