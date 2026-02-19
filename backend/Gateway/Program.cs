using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using ServiceDefaults;

// Enable HTTP/2 without TLS so Gateway can communicate with h2c-only services (e.g. Security API)
AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true);

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

var authority = builder.Configuration["Auth:Authority"];
if (string.IsNullOrWhiteSpace(authority))
    throw new InvalidOperationException("Auth configuration is missing. Expected Auth:Authority.");
var audience = builder.Configuration["Auth:Audience"];
var requireHttpsMetadata = builder.Configuration.GetValue("Auth:RequireHttpsMetadata",
    !builder.Environment.IsDevelopment());

builder.Services
    .AddAuthentication("Bearer")
    .AddJwtBearer("Bearer", options =>
    {
        options.Authority = authority;
        options.RequireHttpsMetadata = requireHttpsMetadata;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateAudience = true,
            ValidAudience = audience
        };
    });

builder.Services.AddAuthorization();

// Configure CORS for frontend
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.WithOrigins("http://localhost:4200", "http://localhost:5173")
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});

builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Medion API Gateway",
        Version = "v1",
        Description = "Unified API gateway for all Medion microservices"
    });

    if (!string.IsNullOrWhiteSpace(authority))
    {
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
    }

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

builder.Services.AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"))
    .AddServiceDiscoveryDestinationResolver();

var app = builder.Build();

// Use global exception handling
app.UseDefaultExceptionHandler();

app.MapDefaultEndpoints();

// Enable CORS
app.UseCors();

app.UseAuthentication();
app.UseAuthorization();

app.UseSwagger();

app.UseSwaggerUI(options =>
{
    options.SwaggerEndpoint("/swagger/v1/swagger.json", "Gateway");

    // Aggregate all service swagger docs
    options.SwaggerEndpoint("/swagger-docs/sale-api/v1/swagger.json", "Sale API");
    options.SwaggerEndpoint("/swagger-docs/approval-api/v1/swagger.json", "Approval API");
    options.SwaggerEndpoint("/swagger-docs/payroll-api/v1/swagger.json", "Payroll API");
    options.SwaggerEndpoint("/swagger-docs/inventory-api/v1/swagger.json", "Inventory API");
    options.SwaggerEndpoint("/swagger-docs/manufacture-api/v1/swagger.json", "Manufacture API");
    options.SwaggerEndpoint("/swagger-docs/security-api/v1/swagger.json", "Security API");

    options.RoutePrefix = "swagger";
    options.ConfigObject.PersistAuthorization = true;

    var oauthClientId = builder.Configuration["Swagger:OAuthClientId"];
    if (!string.IsNullOrWhiteSpace(oauthClientId))
    {
        options.OAuthClientId(oauthClientId);
        options.OAuthUsePkce();
        options.OAuthScopes("openid");
    }
});

app.MapGet("/", () => new { name = "API Gateway", version = 1 });

// Swagger aggregation endpoints - proxy swagger.json from services
// Services using h2c (HTTP/2 without TLS) require explicit HTTP/2 requests
var h2cServices = new HashSet<string> { "security-api" };
var services = new[]
{
    ("sale-api", "Sale API"),
    ("approval-api", "Approval API"),
    ("payroll-api", "Payroll API"),
    ("inventory-api", "Inventory API"),
    ("manufacture-api", "Manufacture API"),
    ("security-api", "Security API")
};

foreach (var (serviceName, label) in services)
    app.MapGet($"/swagger-docs/{serviceName}/v1/swagger.json", async (IHttpClientFactory httpFactory) =>
    {
        try
        {
            var client = httpFactory.CreateClient("AspireClient");

            var request = new HttpRequestMessage(HttpMethod.Get, $"http://{serviceName}/swagger/v1/swagger.json");
            if (h2cServices.Contains(serviceName))
            {
                request.Version = new Version(2, 0);
                request.VersionPolicy = HttpVersionPolicy.RequestVersionExact;
            }

            var response = await client.SendAsync(request);

            if (!response.IsSuccessStatusCode) return Results.StatusCode((int)response.StatusCode);
            var json = await response.Content.ReadAsStringAsync();
            return Results.Content(json, "application/json");
        }
        catch (Exception ex)
        {
            return Results.Json(new { error = ex.Message }, statusCode: 503);
        }
    });

app.MapReverseProxy().RequireAuthorization();

await app.RunAsync();
