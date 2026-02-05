using Identity.API.Filters;
using Identity.API.Middleware;
using Identity.API.Services;
using Identity.Application;
using Identity.Application.Common.Abstractions;
using Identity.Domain.Entities;
using Identity.Domain.Repositories;
using Identity.Infrastructure.Persistence;
using Identity.Infrastructure.Persistence.Repositories;
using Identity.Infrastructure.Services;
using Microsoft.OpenApi.Models;
using ServiceDefaults;

var builder = WebApplication.CreateBuilder(args);

// Load JWT settings from configuration
var jwtSettings = builder.Configuration.GetSection("JwtSettings").Get<JwtSettings>()
                  ?? throw new InvalidOperationException("JwtSettings configuration is missing");

// Add services to DI container
builder.Services.AddSingleton(jwtSettings);

// Database configuration
var connectionString = Environment.GetEnvironmentVariable("CONNECTIONSTRINGS__POSTGRES");

// If Aspire env var not set, use config
if (string.IsNullOrEmpty(connectionString))
    connectionString = builder.Configuration.GetConnectionString("postgres")
                       ?? builder.Configuration.GetConnectionString("DefaultConnection");

connectionString = connectionString ?? throw new InvalidOperationException("Connection string not found.");

builder.Services.AddDbContext<IdentityDbContext>(options =>
    options.UseNpgsql(connectionString, npgsqlOptions =>
        npgsqlOptions.MigrationsAssembly("Identity.Infrastructure")));

// Identity services
builder.Services.AddIdentity<User, Role>(options =>
    {
        options.Password.RequiredLength = 8;
        options.Password.RequireDigit = true;
        options.Password.RequireLowercase = true;
        options.Password.RequireUppercase = true;
        options.Password.RequireNonAlphanumeric = false;
        options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
        options.Lockout.MaxFailedAccessAttempts = 5;
        options.User.RequireUniqueEmail = true;
        options.SignIn.RequireConfirmedEmail = false;
    })
    .AddEntityFrameworkStores<IdentityDbContext>()
    .AddDefaultTokenProviders();

// JWT Authentication configuration
builder.Services.AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer(options =>
    {
        var key = Encoding.ASCII.GetBytes(jwtSettings.Secret);
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(key),
            ValidateIssuer = true,
            ValidIssuer = jwtSettings.Issuer,
            ValidateAudience = true,
            ValidAudience = jwtSettings.Audience,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero
        };
    });

builder.Services.AddAuthorization();

// CQRS + Mapster (Application layer)
builder.Services.AddApplicationServices();

// Repositories
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IRoleRepository, RoleRepository>();

// Services
builder.Services.AddScoped<ITokenService, JwtTokenService>();
builder.Services.AddScoped<TokenVerificationService>();

// Add password hasher for manual user creation
builder.Services.AddScoped<IPasswordHasher<User>, PasswordHasher<User>>();

// Add Memory Cache for token blacklist
builder.Services.AddMemoryCache();

// Register Token Blacklist Service
builder.Services.AddSingleton<ITokenBlacklistService, TokenBlacklistService>();

// Register CheckTokenBlacklistFilter in DI
builder.Services.AddScoped<CheckTokenBlacklistFilter>();

// gRPC services
builder.Services.AddGrpc().AddJsonTranscoding();

// Controllers (optional REST endpoints)
builder.Services.AddControllers(options =>
{
    // Add global filter to check token blacklist
    options.Filters.Add<CheckTokenBlacklistFilter>();
});

// API documentation
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Identity API",
        Version = "v1",
        Description = "Identity and Authentication Service"
    });

    c.AddServer(new OpenApiServer
    {
        Url = "/api/identity",
        Description = "Identity API"
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

// CORS - Allow from gateway and localhost development
builder.Services.AddCors(options =>
{
    var isDevelopment = builder.Environment.IsDevelopment();

    if (isDevelopment)
        // In development, allow any localhost origin
        options.AddDefaultPolicy(policyBuilder =>
        {
            policyBuilder
                .WithOrigins(
                    "http://localhost",
                    "http://localhost:5000", // Gateway
                    "http://localhost:4200", // Frontend
                    "http://localhost:5001", // Direct Identity API
                    "https://localhost",
                    "https://localhost:5000", // Gateway HTTPS
                    "https://localhost:4200", // Frontend HTTPS
                    "https://localhost:5001" // Direct Identity API HTTPS
                )
                .AllowAnyMethod()
                .AllowAnyHeader()
                .AllowCredentials();
        });
    else
        // Production - restrict to known origins
        options.AddDefaultPolicy(policyBuilder =>
        {
            policyBuilder
                .WithOrigins(
                    "https://app.medion.com"
                )
                .AllowAnyMethod()
                .AllowAnyHeader()
                .AllowCredentials();
        });
});

var app = builder.Build();

// Use global exception handling
app.UseDefaultExceptionHandler();

// Middleware pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors();

// Allow gateway-style prefix when calling Identity API directly
app.UsePathPrefixRewrite("/api/identity");

app.UseAuthentication();
app.UseAuthorization();

// Map controllers
app.MapControllers();

// gRPC endpoints
app.MapGrpcService<TokenVerificationService>();

// Health check endpoint
app.MapGet("/health", () => new { status = "healthy", timestamp = DateTime.UtcNow });

// Root endpoint
app.MapGet("/", () => new { service = "Identity.API", version = "1.0" });

// Database migrations with retry (best effort on startup)
var maxRetries = 5;
var delay = TimeSpan.FromSeconds(2);

for (var i = 0; i < maxRetries; i++)
    try
    {
        using var scope = app.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<IdentityDbContext>();
        var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
        logger.LogInformation("Starting database migration (attempt {Attempt}/{MaxRetries})...", i + 1, maxRetries);
        await db.Database.MigrateAsync();
        logger.LogInformation("Database migration completed successfully");
        break;
    }
    catch (Exception ex)
    {
        var logger = app.Services.CreateScope().ServiceProvider.GetRequiredService<ILogger<Program>>();

        if (i < maxRetries - 1)
        {
            logger.LogWarning(ex,
                "Database migration failed, retrying in {Delay}ms... (attempt {Attempt}/{MaxRetries})",
                delay.TotalMilliseconds, i + 1, maxRetries);
            await Task.Delay(delay);
        }
        else
        {
            logger.LogError(ex, "Database migration failed after {MaxRetries} attempts", maxRetries);
        }
    }

await app.RunAsync();
