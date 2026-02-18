using MassTransit;
using Medion.Shared.Events;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Sale.API.Middleware;
using Sale.API.Serialization;
using Sale.API.Swagger;
using Sale.Application;
using Sale.Domain.Identifiers;
using Sale.Domain.Identifiers.Id;
using Sale.Infrastructure;
using Sale.Infrastructure.Data;
using ServiceDefaults;
using SharedStorage;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

var authSection = builder.Configuration.GetSection("Auth");
var authority = authSection["Authority"];
var audience = authSection["Audience"];
if (string.IsNullOrWhiteSpace(authority) || string.IsNullOrWhiteSpace(audience))
{
    throw new InvalidOperationException("Auth configuration is missing. Expected Auth:Authority and Auth:Audience.");
}

// Add Application and Infrastructure services
builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureServices(builder.Configuration);

// Register HttpContextAccessor (required by AuditLoggingBehavior)
builder.Services.AddHttpContextAccessor();

// Register TransactionContext (scoped, for passing signature through pipeline)
builder.Services.AddScoped<Sale.Application.Common.Context.TransactionContext>();

// Register TransactionSigningBehavior (needs gRPC client, so in API layer)
builder.Services.AddScoped(typeof(MediatR.IPipelineBehavior<,>), typeof(Sale.API.Behaviors.TransactionSigningBehavior<,>));

// Services
builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.Converters.Add(new StronglyTypedIdJsonConverter<CustomerId>());
    options.JsonSerializerOptions.Converters.Add(new StronglyTypedIdJsonConverter<UserId>());
    options.JsonSerializerOptions.Converters.Add(new StronglyTypedIdJsonConverter<ProductId>());
    options.JsonSerializerOptions.Converters.Add(new StronglyTypedIdJsonConverter<OrderId>());
    options.JsonSerializerOptions.Converters.Add(new StronglyTypedIdJsonConverter<OrderItemId>());
});
builder.Services.AddGrpc(o => { o.EnableDetailedErrors = true; }).AddJsonTranscoding();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Sale API",
        Version = "v1"
    });

    var idTypes = typeof(IStronglyTypedId).Assembly.GetTypes()
        .Where(t => typeof(IStronglyTypedId).IsAssignableFrom(t) && !t.IsInterface && !t.IsAbstract);

    foreach (var idType in idTypes)
    {
        c.MapType(idType, () => new OpenApiSchema
        {
            Type = "string",
            Format = "uuid"
        });
    }

    c.AddServer(new OpenApiServer
    {
        Url = "/api/sale",
        Description = "Sale API"
    });

    // Add custom header for transaction password (required for sensitive operations)
    c.OperationFilter<TransactionPasswordHeaderFilter>();

    var authorizationUrl = new Uri($"{authority}/protocol/openid-connect/auth");
    var tokenUrl = new Uri($"{authority}/protocol/openid-connect/token");

    c.AddSecurityDefinition("oauth2", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.OAuth2,
        Flows = new OpenApiOAuthFlows
        {
            AuthorizationCode = new OpenApiOAuthFlow
            {
                AuthorizationUrl = authorizationUrl,
                TokenUrl = tokenUrl,
                Scopes = new Dictionary<string, string>
                {
                    { "openid", "OpenID" }
                }
            }
        }
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "oauth2"
                }
            },
            new[] { "openid" }
        }
    });
});

builder.Services.AddGrpcReflection();

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = authority;
        options.Audience = audience;
        options.RequireHttpsMetadata = !builder.Environment.IsDevelopment();
        options.MapInboundClaims = false;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidIssuer = authority,
            NameClaimType = "preferred_username",
            RoleClaimType = "roles"
        };
    });

builder.Services.AddAuthorization();

// Add S3 Storage
builder.Services.AddS3Storage(builder.Configuration);

// MassTransit with RabbitMQ - Configure for event publishing with Outbox pattern
builder.Services.AddMassTransit(x =>
{
    // Publish events in kebab-case by default
    x.SetKebabCaseEndpointNameFormatter();

    // ✅ Configure MassTransit Outbox with EF Core
    // This ensures events are saved to database before being published to RabbitMQ
    // If service crashes, events remain in outbox and are published when service restarts
    x.AddEntityFrameworkOutbox<SaleDbContext>(o =>
    {
        // Use database transport to read from outbox
        o.UsePostgres();  // or o.UseSqlite() if using SQLite

        // Configure how often to check for outbox messages
        o.QueryDelay = TimeSpan.FromSeconds(3);
    });

    // Configure RabbitMQ as the transport
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

        // Align exchange name with Audit.API consumer
        cfg.Message<AuditLogIntegrationEvent>(x => x.SetEntityName("audit-log-events"));

        cfg.ConfigureEndpoints(context);
    });
});

// Register gRPC clients for inter-service communication
// Debug: Print all security-api related config and env vars
Console.WriteLine("[Sale.API] === Security Service Discovery Debug ===");
Console.WriteLine("[Sale.API] --- Environment Variables with 'security' ---");
foreach (var ev in Environment.GetEnvironmentVariables().Cast<System.Collections.DictionaryEntry>()
    .Where(x => x.Key.ToString()!.Contains("security", StringComparison.OrdinalIgnoreCase)))
{
    Console.WriteLine($"[Sale.API] EnvVar: {ev.Key} = {ev.Value}");
}
Console.WriteLine("[Sale.API] --- Configuration with 'security' ---");
foreach (var kv in builder.Configuration.AsEnumerable().Where(x => x.Key.Contains("security", StringComparison.OrdinalIgnoreCase)))
{
    Console.WriteLine($"[Sale.API] Config: {kv.Key} = {kv.Value}");
}
Console.WriteLine("[Sale.API] === End Config Dump ===");

// Try explicit config override first
var securityGrpcUrl = builder.Configuration["SecurityService:GrpcUrl"];

// Try Aspire-injected service endpoints (various formats)
var discoveredSecurityUrl = builder.Configuration["services:security-api:http:0"]
    ?? builder.Configuration["services:security-api:https:0"]
    ?? builder.Configuration.GetConnectionString("security-api");

// Resolve final address
Uri securityGrpcAddress;
if (!string.IsNullOrWhiteSpace(securityGrpcUrl))
{
    securityGrpcAddress = new Uri(securityGrpcUrl);
    Console.WriteLine($"[Sale.API] Using explicit config: {securityGrpcAddress}");
}
else if (!string.IsNullOrWhiteSpace(discoveredSecurityUrl))
{
    securityGrpcAddress = new Uri(discoveredSecurityUrl);
    Console.WriteLine($"[Sale.API] Using Aspire-discovered URL: {securityGrpcAddress}");
}
else
{
    // Hardcoded fallback for local development (matches Security.API appsettings.Development.json)
    securityGrpcAddress = new Uri("http://127.0.0.1:5001");
    Console.WriteLine($"[Sale.API] Using hardcoded fallback: {securityGrpcAddress}");
}

// Log resolved address at startup for debugging
Console.WriteLine($"[Sale.API] Security gRPC address FINAL: {securityGrpcAddress}");

builder.Services.AddGrpcClient<Security.API.Grpc.SignatureService.SignatureServiceClient>(o =>
{
    o.Address = securityGrpcAddress;
})
.ConfigurePrimaryHttpMessageHandler(() =>
{
    // For unencrypted HTTP/2 (gRPC over plain HTTP), we need to configure the handler
    return new SocketsHttpHandler
    {
        KeepAlivePingDelay = TimeSpan.FromSeconds(60),
        KeepAlivePingTimeout = TimeSpan.FromSeconds(30),
        EnableMultipleHttp2Connections = true
    };
})
.ConfigureChannel(o =>
{
    // Force HTTP/2 for unencrypted gRPC connections
    o.HttpVersion = new Version(2, 0);
    o.HttpVersionPolicy = HttpVersionPolicy.RequestVersionExact;
});

var app = builder.Build();

// Auto-migrate database on startup with retry logic
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<SaleDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();

    // Retry database migration up to 10 times with exponential backoff
    var maxRetries = 10;
    var retryDelay = TimeSpan.FromSeconds(2);

    for (int attempt = 1; attempt <= maxRetries; attempt++)
    {
        try
        {
            logger.LogInformation("Attempting database migration (attempt {Attempt}/{MaxRetries})...", attempt, maxRetries);
            await dbContext.Database.MigrateAsync();
            logger.LogInformation("Database migration completed successfully");
            break;
        }
        catch (Npgsql.PostgresException ex) when (ex.SqlState == "57P03") // Database starting up
        {
            if (attempt == maxRetries)
            {
                logger.LogError(ex, "Failed to connect to database after {MaxRetries} attempts", maxRetries);
                throw;
            }

            logger.LogWarning("Database is starting up. Waiting {Delay} seconds before retry {Attempt}/{MaxRetries}...",
                retryDelay.TotalSeconds, attempt, maxRetries);
            await Task.Delay(retryDelay);
            retryDelay = TimeSpan.FromSeconds(retryDelay.TotalSeconds * 1.5); // Exponential backoff
        }
    }
}

// Use global exception handling
app.UseDefaultExceptionHandler();

app.UseSwagger();
app.UsePathPrefixRewrite("/api/sale");
app.UseAuthentication();
app.UseAuthorization();
app.MapDefaultEndpoints();

// Map Controllers
app.MapControllers();

// NOTE: CD pipeline also runs migrations; app startup keeps auto-migrate enabled
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
