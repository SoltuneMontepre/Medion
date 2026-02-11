using Approval.API.Middleware;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using ServiceDefaults;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

var authSection = builder.Configuration.GetSection("Auth");
var authority = authSection["Authority"];
var audience = authSection["Audience"];
var publicAuthority = authSection["PublicAuthority"];
var tokenIssuer = authSection["TokenIssuer"];
var swaggerAuthority = string.IsNullOrWhiteSpace(publicAuthority) ? authority : publicAuthority;
if (string.IsNullOrWhiteSpace(authority) || string.IsNullOrWhiteSpace(audience))
{
    throw new InvalidOperationException("Auth configuration is missing. Expected Auth:Authority and Auth:Audience.");
}
if (string.IsNullOrWhiteSpace(tokenIssuer))
{
    tokenIssuer = authority;
}
builder.Services.AddGrpc().AddJsonTranscoding();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Approval API",
        Version = "v1"
    });

    c.AddServer(new OpenApiServer
    {
        Url = "/api/approval",
        Description = "Approval API"
    });

    var authorizationUrl = new Uri($"{swaggerAuthority}/protocol/openid-connect/auth");
    var tokenUrl = new Uri($"{swaggerAuthority}/protocol/openid-connect/token");

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

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = authority;
        options.Audience = audience;
        options.RequireHttpsMetadata = !builder.Environment.IsDevelopment();
        options.MapInboundClaims = false;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidIssuer = tokenIssuer,
            NameClaimType = "preferred_username",
            RoleClaimType = "roles"
        };
    });

builder.Services.AddAuthorization();

var app = builder.Build();

// Use global exception handling
app.UseDefaultExceptionHandler();

app.UseSwagger();
app.UsePathPrefixRewrite("/api/approval");
app.UseAuthentication();
app.UseAuthorization();

app.MapGet("/", () => new { name = "Approval.API" });

await app.RunAsync();
