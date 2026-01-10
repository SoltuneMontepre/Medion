var builder = WebApplication.CreateBuilder(args);

builder.Services.AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

var app = builder.Build();

app.MapGet("/", () => new { name = "API Gateway", version = 1 });
app.MapReverseProxy();

app.Run();
