var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();
app.MapGet("/", () => new { name = "Payroll.API" });
app.Run();
