using Microsoft.OpenApi.Models;
using ServiceDefaults;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

// Configure CORS for frontend
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.WithOrigins("http://localhost:4200")
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

builder.Services.AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"))
    .AddServiceDiscoveryDestinationResolver();

var app = builder.Build();

// Use global exception handling
app.UseDefaultExceptionHandler();

app.MapDefaultEndpoints();

// Enable CORS
app.UseCors();

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
    options.SwaggerEndpoint("/swagger-docs/identity-api/v1/swagger.json", "Identity API");

    options.RoutePrefix = "swagger";
});

app.MapGet("/", () => new { name = "API Gateway", version = 1 });

// Swagger aggregation endpoints - proxy swagger.json from services
var services = new[]
{
    ("sale-api", "Sale API"),
    ("approval-api", "Approval API"),
    ("payroll-api", "Payroll API"),
    ("inventory-api", "Inventory API"),
    ("manufacture-api", "Manufacture API"),
    ("identity-api", "Identity API")
};

foreach (var (serviceName, label) in services)
    app.MapGet($"/swagger-docs/{serviceName}/v1/swagger.json", async (IHttpClientFactory httpFactory) =>
    {
        try
        {
            var client = httpFactory.CreateClient("AspireClient");

            var response = await client.GetAsync($"http://{serviceName}/swagger/v1/swagger.json");

            if (!response.IsSuccessStatusCode) return Results.StatusCode((int)response.StatusCode);
            var json = await response.Content.ReadAsStringAsync();
            return Results.Content(json, "application/json");
        }
        catch (Exception ex)
        {
            return Results.Json(new { error = ex.Message }, statusCode: 503);
        }
    });

app.MapReverseProxy();

await app.RunAsync();
