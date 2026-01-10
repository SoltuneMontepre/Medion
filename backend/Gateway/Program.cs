using Microsoft.OpenApi.Models;
using ServiceDefaults;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Medion API Gateway",
        Version = "v1",
        Description = "Unified API gateway for all Medion microservices"
    });
});

builder.Services.AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

var app = builder.Build();

app.MapDefaultEndpoints();

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

            if (response.IsSuccessStatusCode)
            {
                var json = await response.Content.ReadAsStringAsync();
                return Results.Content(json, "application/json");
            }

            return Results.StatusCode((int)response.StatusCode);
        }
        catch (Exception ex)
        {
            return Results.Json(new { error = ex.Message }, statusCode: 503);
        }
    });

app.MapReverseProxy();

await app.RunAsync();
