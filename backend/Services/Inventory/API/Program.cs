var builder = WebApplication.CreateBuilder(args);

builder.Services.AddGrpc().AddJsonTranscoding();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();

app.MapGet("/", () => new { name = "Inventory.API" });

await app.RunAsync();
