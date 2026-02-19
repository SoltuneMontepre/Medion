using System.Net.Sockets;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Npgsql;
using Security.API.Grpc;
using Security.Application.Features.Signature.Commands;
using Security.Infrastructure;
using Security.Infrastructure.Data;
using ServiceDefaults;

var builder = WebApplication.CreateBuilder(args);

// Optimize Kestrel for high-throughput service-to-service signing
// Protocol (Http2) is set via appsettings Kestrel:EndpointDefaults:Protocols
builder.WebHost.ConfigureKestrel(options =>
{
    options.Limits.MaxConcurrentConnections = 500;
    options.Limits.MaxConcurrentUpgradedConnections = 500;
    options.Limits.Http2.MaxStreamsPerConnection = 250;
    options.Limits.Http2.InitialConnectionWindowSize = 1024 * 1024;       // 1 MB
    options.Limits.Http2.InitialStreamWindowSize = 768 * 1024;            // 768 KB
    options.Limits.KeepAliveTimeout = TimeSpan.FromMinutes(2);
    options.Limits.RequestHeadersTimeout = TimeSpan.FromSeconds(30);
});

builder.AddServiceDefaults();

var authSection = builder.Configuration.GetSection("Auth");
var authority = authSection["Authority"];
var audience = authSection["Audience"];
if (string.IsNullOrWhiteSpace(authority) || string.IsNullOrWhiteSpace(audience))
    throw new InvalidOperationException("Auth configuration is missing. Expected Auth:Authority and Auth:Audience.");

builder.Services.AddGrpc(o => { o.EnableDetailedErrors = true; }).AddJsonTranscoding();
builder.Services.AddGrpcReflection();
builder.Services.AddHealthChecks();
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Security API",
        Version = "v1",
        Description = "Security service for transaction signatures and PIN management"
    });

    c.AddServer(new OpenApiServer
    {
        Url = "/api/security",
        Description = "Security API"
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

// Register MediatR for command/query handling
builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblyContaining<CreateSignatureCommand>());

builder.Services.AddInfrastructureServices(builder.Configuration);

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

var app = builder.Build();

// Auto-migrate database on startup with retry logic
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<SecurityDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();

    var maxRetries = 10;
    var retryDelay = TimeSpan.FromSeconds(2);

    for (var attempt = 1; attempt <= maxRetries; attempt++)
        try
        {
            logger.LogInformation("Attempting database migration (attempt {Attempt}/{MaxRetries})...", attempt,
                maxRetries);

            var hasMigrations = dbContext.Database.GetMigrations().Any();
            if (hasMigrations)
                await dbContext.Database.MigrateAsync();
            else
                await dbContext.Database.EnsureCreatedAsync();

            logger.LogInformation("Database initialized successfully");
            break;
        }
        catch (PostgresException ex) when (ex.SqlState == "57P03") // Database starting up
        {
            if (attempt == maxRetries)
            {
                logger.LogError(ex, "Failed to connect to database after {MaxRetries} attempts", maxRetries);
                throw;
            }

            logger.LogWarning("Database is starting up, retrying in {Delay} seconds...", retryDelay.TotalSeconds);
            await Task.Delay(retryDelay);
            retryDelay = TimeSpan.FromSeconds(retryDelay.TotalSeconds * 1.5); // Exponential backoff
        }
        catch (SocketException ex) // DNS/Network errors
        {
            if (attempt == maxRetries)
            {
                logger.LogError(ex, "Failed to connect to database after {MaxRetries} attempts", maxRetries);
                throw;
            }

            logger.LogWarning("Network error connecting to database, retrying in {Delay} seconds...",
                retryDelay.TotalSeconds);
            await Task.Delay(retryDelay);
            retryDelay = TimeSpan.FromSeconds(retryDelay.TotalSeconds * 1.5);
        }
}

app.UseDefaultExceptionHandler();
app.UseSwagger();
app.UseSwaggerUI();
app.UseAuthentication();
app.UseAuthorization();
app.MapDefaultEndpoints();

app.MapGrpcService<SignatureGrpcService>();
app.MapGrpcReflectionService();
app.MapControllers();

app.MapGet("/", () => new { name = "Security.API", grpc = "/medion.security.v1.SignatureService" });
app.MapHealthChecks("/health");

await app.RunAsync();
