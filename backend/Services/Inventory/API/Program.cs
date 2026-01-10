var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();
app.MapGet("/", () => new { name = "Inventory.API" });
app.Run();
