using MassTransit;
using Medion.Shared.Events;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Sale.API.Middleware;
using Sale.API.Serialization;
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

// MassTransit with RabbitMQ - Configure for event publishing
builder.Services.AddMassTransit(x =>
{
    // Publish events in kebab-case by default
    x.SetKebabCaseEndpointNameFormatter();

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

        cfg.ConfigureEndpoints(context);
    });
});

// Register gRPC clients for inter-service communication
builder.Services.AddGrpcClient<Security.API.Grpc.SignatureService.SignatureServiceClient>(o =>
{
    // Aspire service discovery will automatically resolve "security-api" hostname
    o.Address = new Uri("http://security-api:8080");
})
.ConfigureChannel(o =>
{
    o.HttpHandler = new SocketsHttpHandler
    {
        KeepAlivePingDelay = TimeSpan.FromSeconds(60),
        KeepAlivePingTimeout = TimeSpan.FromSeconds(30),
        UseDnsCache = true
    };
});

var app = builder.Build();

// Auto-migrate database on startup
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<SaleDbContext>();
    await dbContext.Database.MigrateAsync();
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
