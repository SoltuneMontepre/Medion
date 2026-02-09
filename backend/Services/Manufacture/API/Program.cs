using Manufacture.API.Middleware;
using Microsoft.OpenApi.Models;
using ServiceDefaults;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

builder.Services.AddGrpc().AddJsonTranscoding();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Manufacture API",
        Version = "v1"
    });

    c.AddServer(new OpenApiServer
    {
        Url = "/api/manufacture",
        Description = "Manufacture API"
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

var app = builder.Build();

// Use global exception handling
app.UseDefaultExceptionHandler();

app.UseSwagger();
app.UsePathPrefixRewrite("/api/manufacture");

app.MapGet("/", () => new { name = "Manufacture.API" });
app.MapGet("/health", () => Results.Ok(new { status = "Healthy" }));

await app.RunAsync();
