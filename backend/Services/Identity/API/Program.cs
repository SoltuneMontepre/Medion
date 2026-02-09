using Identity.API.Filters;
using Identity.API.Middleware;
using Identity.API.Serialization;
using Identity.API.Services;
using Identity.Application;
using Identity.Application.Common.Abstractions;
using Identity.Domain.Entities;
using Identity.Domain.Identifiers;
using Identity.Domain.Repositories;
using Identity.Infrastructure.Persistence;
using Identity.Infrastructure.Persistence.Repositories;
using Identity.Infrastructure.Services;
using Microsoft.OpenApi.Models;
using ServiceDefaults;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

// Load JWT settings from configuration
var jwtSettings = builder.Configuration.GetSection("JwtSettings").Get<JwtSettings>()
                  ?? throw new InvalidOperationException("JwtSettings configuration is missing");

// Add services to DI container
builder.Services.AddSingleton(jwtSettings);

// Database configuration - Aspire uses resource name from AppHost.cs: "postgres-identity"
var connectionString = builder.Configuration.GetConnectionString("postgres-identity")
                       ?? builder.Configuration.GetConnectionString("DefaultConnection")
                       ?? throw new InvalidOperationException("Connection string not found.");

builder.Services.AddDbContext<IdentityDbContext>(options =>
{
    options.UseNpgsql(connectionString, npgsqlOptions =>
    {
        npgsqlOptions.MigrationsAssembly("Identity.Infrastructure");
        // Optimize for Lambda: reduce connection timeout and enable pooling
        npgsqlOptions.CommandTimeout(30);
        npgsqlOptions.EnableRetryOnFailure(maxRetryCount: 3);
    });

    // Disable sensitive data logging in production for performance
    if (!builder.Environment.IsDevelopment())
    {
        options.EnableSensitiveDataLogging(false);
        options.EnableDetailedErrors(false);
    }
});

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

// Data Protection: Use default ephemeral in-memory keys for Lambda
// Lambda functions are stateless and ephemeral, so persistent key storage doesn't help
// If cross-instance key persistence is needed, use AWS Systems Manager Parameter Store

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
}).AddJsonOptions(options =>
{
    options.JsonSerializerOptions.Converters.Add(new StronglyTypedIdJsonConverter<IdentityId>());
});

// API documentation
builder.Services.AddEndpointsApiExplorer();

// Only register Swagger in Development
if (builder.Environment.IsDevelopment())
{
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
}

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

// Auto-migrate database in Development environment (for Aspire local development)
if (app.Environment.IsDevelopment())
{
    using var scope = app.Services.CreateScope();
    var dbContext = scope.ServiceProvider.GetRequiredService<IdentityDbContext>();
    await dbContext.Database.MigrateAsync();
}

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

// Aspire health checks
app.MapDefaultEndpoints();

// Root endpoint
app.MapGet("/", () => new { service = "Identity.API", version = "1.0" });
app.MapGet("/health", () => Results.Ok(new { status = "Healthy" }));

await app.RunAsync();
