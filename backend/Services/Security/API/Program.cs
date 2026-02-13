using Microsoft.EntityFrameworkCore;
using Security.API.Grpc;
using Security.Infrastructure;
using Security.Infrastructure.Data;
using ServiceDefaults;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

builder.Services.AddGrpc(o => { o.EnableDetailedErrors = true; }).AddJsonTranscoding();
builder.Services.AddGrpcReflection();
builder.Services.AddHealthChecks();

builder.Services.AddInfrastructureServices(builder.Configuration);

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
  var dbContext = scope.ServiceProvider.GetRequiredService<SecurityDbContext>();
  var hasMigrations = dbContext.Database.GetMigrations().Any();
  if (hasMigrations)
    await dbContext.Database.MigrateAsync();
  else
    await dbContext.Database.EnsureCreatedAsync();
}

app.UseDefaultExceptionHandler();
app.MapDefaultEndpoints();

app.MapGrpcService<SignatureGrpcService>();
app.MapGrpcReflectionService();

app.MapGet("/", () => new { name = "Security.API", grpc = "/medion.security.v1.SignatureService" });
app.MapHealthChecks("/health");

await app.RunAsync();
