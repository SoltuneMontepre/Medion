using Audit.API.Grpc;
using Audit.Application;
using Audit.Infrastructure;
using Audit.Infrastructure.Data;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using ServiceDefaults;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

// Add gRPC services
builder.Services.AddGrpc(o => { o.EnableDetailedErrors = true; }).AddJsonTranscoding();
builder.Services.AddGrpcReflection();
builder.Services.AddHealthChecks();

// Add application layer services
builder.Services.AddAuditApplicationServices();

// Add infrastructure services (database, repositories, Vault client)
builder.Services.AddAuditInfrastructureServices(builder.Configuration);

// Configure MassTransit with RabbitMQ for event consumption
builder.Services.AddMassTransit(x =>
{
    // Register the consumer for CustomerCreatedIntegrationEvent
    x.AddConsumer<Audit.Application.IntegrationEvents.Consumers.CustomerCreatedAuditConsumer>();

    x.UsingRabbitMq((context, cfg) =>
    {
        // Get connection string from configuration
        var configuration = context.GetService<IConfiguration>();
        var connectionString = configuration?.GetConnectionString("rabbitmq");

        if (!string.IsNullOrEmpty(connectionString))
        {
            var uri = new Uri(connectionString);
            cfg.Host(uri);
        }
        else
        {
            // Local development fallback
            cfg.Host("localhost", h =>
            {
              h.Username("guest");
              h.Password("guest");
          });
        }

        // Configure the customer-created audit consumer
        cfg.ReceiveEndpoint("audit-customer-created", e =>
        {
            // Bind consumer to this endpoint
            e.ConfigureConsumer<Audit.Application.IntegrationEvents.Consumers.CustomerCreatedAuditConsumer>(context);

            // Retry policy: retry up to 5 times with incremental backoff
            e.UseRetry(r => r.Incremental(5, TimeSpan.FromSeconds(1), TimeSpan.FromSeconds(1)));

            // Concurrency: process up to 10 messages in parallel
            e.PrefetchCount = 10;

            // Instance ID for distributed tracing
            e.InstanceId = "audit-01";
        });

        cfg.ConfigureEndpoints(context);
    });
});

var app = builder.Build();

// Database initialization
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<AuditDbContext>();
    var hasMigrations = dbContext.Database.GetMigrations().Any();
    if (hasMigrations)
        await dbContext.Database.MigrateAsync();
    else
        await dbContext.Database.EnsureCreatedAsync();
}

app.UseDefaultExceptionHandler();
app.MapDefaultEndpoints();

// Map gRPC services
app.MapGrpcService<AuditGrpcService>();
app.MapGrpcReflectionService();

// Health check and info endpoints
app.MapGet("/", () => new { name = "Audit.API", grpc = "/medion.audit.v1.AuditService" });
app.MapHealthChecks("/health");

await app.RunAsync();

