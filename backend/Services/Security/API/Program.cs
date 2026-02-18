using Microsoft.EntityFrameworkCore;
using Security.API.Grpc;
using Security.API.Services;
using Security.Application.Features.Signature.Commands;
using Security.Infrastructure;
using Security.Infrastructure.Data;
using ServiceDefaults;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

builder.Services.AddGrpc(o => { o.EnableDetailedErrors = true; }).AddJsonTranscoding();
builder.Services.AddGrpcReflection();
builder.Services.AddHealthChecks();

// Register MediatR for command/query handling
builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblyContaining<CreateSignatureCommand>());

builder.Services.AddInfrastructureServices(builder.Configuration);

var app = builder.Build();

// Auto-migrate database on startup with retry logic
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<SecurityDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();

    var maxRetries = 10;
    var retryDelay = TimeSpan.FromSeconds(2);

    for (int attempt = 1; attempt <= maxRetries; attempt++)
    {
        try
        {
            logger.LogInformation("Attempting database migration (attempt {Attempt}/{MaxRetries})...", attempt, maxRetries);

            var hasMigrations = dbContext.Database.GetMigrations().Any();
            if (hasMigrations)
                await dbContext.Database.MigrateAsync();
            else
                await dbContext.Database.EnsureCreatedAsync();

            logger.LogInformation("Database initialized successfully");
            break;
        }
        catch (Npgsql.PostgresException ex) when (ex.SqlState == "57P03") // Database starting up
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
        catch (System.Net.Sockets.SocketException ex) // DNS/Network errors
        {
            if (attempt == maxRetries)
            {
                logger.LogError(ex, "Failed to connect to database after {MaxRetries} attempts", maxRetries);
                throw;
            }
            logger.LogWarning("Network error connecting to database, retrying in {Delay} seconds...", retryDelay.TotalSeconds);
            await Task.Delay(retryDelay);
            retryDelay = TimeSpan.FromSeconds(retryDelay.TotalSeconds * 1.5);
        }
    }
}

app.UseDefaultExceptionHandler();
app.MapDefaultEndpoints();

app.MapGrpcService<SignatureGrpcService>();
app.MapGrpcReflectionService();

app.MapGet("/", () => new { name = "Security.API", grpc = "/medion.security.v1.SignatureService" });
app.MapHealthChecks("/health");

await app.RunAsync();
