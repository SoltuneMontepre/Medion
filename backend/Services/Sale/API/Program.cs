using MassTransit;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using Sale.API.Grpc;
using Sale.API.Middleware;
using Sale.Application.Abstractions;
using Sale.Infrastructure.Data;
using ServiceDefaults;
using SharedStorage;

var builder = WebApplication.CreateBuilder(args);

// Config
var postgres = builder.Configuration.GetConnectionString("Postgres")
               ?? Environment.GetEnvironmentVariable("CONNECTIONSTRINGS__POSTGRES")
               ?? "Host=localhost;Port=5432;Username=postgres;Password=postgres;Database=sale";
var rabbitmq = builder.Configuration.GetConnectionString("RabbitMq")
               ?? Environment.GetEnvironmentVariable("CONNECTIONSTRINGS__RABBITMQ")
               ?? "amqp://guest:guest@localhost:5672";

// Services
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

builder.Services.AddDbContext<SaleDbContext>(opt =>
    opt.UseNpgsql(postgres));

builder.Services.AddScoped<IOrderRepository, OrderRepository>();

// Add S3 Storage
builder.Services.AddS3Storage(builder.Configuration);

builder.Services.AddMassTransit(x =>
{
    x.SetKebabCaseEndpointNameFormatter();
    x.UsingRabbitMq((context, cfg) => { cfg.Host(new Uri(rabbitmq)); });
});

var app = builder.Build();

// Use global exception handling
app.UseDefaultExceptionHandler();

app.UseSwagger();
app.UsePathPrefixRewrite("/api/sale");

// NOTE: Database migrations are now handled in the CD pipeline
// See .github/workflows/sale-cd.yml for the migration step

// Endpoints
app.MapGrpcService<SaleService>();
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
