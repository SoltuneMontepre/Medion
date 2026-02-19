using Audit.Application.Common.Repositories;
using Audit.Application.Features.AuditLog.EventHandlers;
using Audit.Infrastructure.Persistence.Repositories;
using MassTransit;
using Microsoft.Extensions.Logging;
using MongoDB.Driver;
using ServiceDefaults;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

// MongoDB configuration - Aspire provides "mongodb" connection string
var mongoConnectionString = builder.Configuration.GetConnectionString("mongodb")
                            ?? throw new InvalidOperationException("MongoDB connection string not found");

var mongoUrl = MongoUrl.Create(mongoConnectionString);
var mongoClient = new MongoClient(mongoUrl);
var database = mongoClient.GetDatabase("medion_audit");

builder.Services.AddSingleton<IMongoDatabase>(database);
builder.Services.AddScoped<IAuditLogRepository, AuditLogRepository>();

// MassTransit with RabbitMQ
builder.Services.AddMassTransit(x =>
{
    x.AddConsumer<AuditLogIntegrationEventConsumer>();

    x.UsingRabbitMq((context, cfg) =>
    {
        var connectionString = builder.Configuration.GetConnectionString("rabbitMq")
                               ?? "amqp://guest:guest@localhost:5672";

        var uri = new Uri(connectionString);
        cfg.Host(uri);

        cfg.ConfigureEndpoints(context);

        // Configure exchange and queue for audit events
        cfg.Message<Medion.Shared.Events.AuditLogIntegrationEvent>(
            x => x.SetEntityName("audit-log-events"));

        cfg.ReceiveEndpoint("audit-log-consumer", e =>
        {
            e.ConfigureConsumer<AuditLogIntegrationEventConsumer>(context);
        });
    });
});

builder.Services.AddEndpointsApiExplorer();
// builder.Services.AddSwaggerGen(); // Swagger JSON only - UI provided by Gateway

var app = builder.Build();

// app.UseSwagger();            // Swagger JSON only - UI provided by Gateway
// app.UseSwaggerUI();           // Swagger JSON only - UI provided by Gateway
app.UseHttpsRedirection();

// Health checks
app.MapDefaultEndpoints();

// Simple health endpoint
app.MapGet("/", () => new { service = "Audit.API", version = "1.0" });

await app.RunAsync();
