using MassTransit;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using Sale.API.Middleware;
using Sale.Application;
using Sale.Infrastructure;
using Sale.Infrastructure.Data;
using ServiceDefaults;
using SharedStorage;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

// Add Application and Infrastructure services
builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureServices(builder.Configuration);

// Services
builder.Services.AddControllers();
builder.Services.AddGrpc(o => { o.EnableDetailedErrors = true; }).AddJsonTranscoding();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Sale API",
        Version = "v1"
    });

    c.AddServer(new OpenApiServer
    {
        Url = "/api/sale",
        Description = "Sale API"
    });

    // JWT Bearer authentication
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        Description = "Enter the JWT token without 'Bearer ' prefix. Example: eyJhbGc..."
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

builder.Services.AddGrpcReflection();

// Add S3 Storage
builder.Services.AddS3Storage(builder.Configuration);

// MassTransit with RabbitMQ - Aspire-aware configuration
builder.Services.AddMassTransit(x =>
{
    x.SetKebabCaseEndpointNameFormatter();
    x.UsingRabbitMq((context, cfg) =>
    {
        // Get connection string from configuration (injected by Aspire)
        var configuration = context.GetService<IConfiguration>();
        var connectionString = configuration?.GetConnectionString("rabbitmq");

        if (!string.IsNullOrEmpty(connectionString))
        {
            // Aspire provides connection string in format: amqp://user:pass@host:port
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

        cfg.ConfigureEndpoints(context);
    });
});

var app = builder.Build();

// Auto-migrate database in Development environment (for Aspire local development)
if (app.Environment.IsDevelopment())
{
    using var scope = app.Services.CreateScope();
    var dbContext = scope.ServiceProvider.GetRequiredService<SaleDbContext>();
    await dbContext.Database.MigrateAsync();
}

// Use global exception handling
app.UseDefaultExceptionHandler();

app.UseSwagger();
app.UsePathPrefixRewrite("/api/sale");
app.MapDefaultEndpoints();

// Map Controllers
app.MapControllers();

// NOTE: Database migrations are now handled in the CD pipeline
// See .github/workflows/sale-cd.yml for the migration step

// Endpoints
app.MapGrpcReflectionService();

// Health + root info
app.MapGet("/", () => new
{
    name = "Sale.API",
    grpc = "/sale.Sale/",
    http = "/api/sale/*"
});

app.MapGet("/health", () => Results.Ok(new { status = "Healthy", service = "Sale.API", timestamp = DateTime.UtcNow }));
await app.RunAsync();
