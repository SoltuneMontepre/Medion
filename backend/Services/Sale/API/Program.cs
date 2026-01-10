using MassTransit;
using Microsoft.EntityFrameworkCore;
using Sale.API.Grpc;
using Sale.Application.Abstractions;
using Sale.Infrastructure.Data;

var builder = WebApplication.CreateBuilder(args);

// Config
var postgres = builder.Configuration.GetConnectionString("Postgres")
               ?? Environment.GetEnvironmentVariable("CONNECTIONSTRINGS__POSTGRES")
               ?? "Host=localhost;Port=5432;Username=postgres;Password=postgres;Database=sale";
var rabbitmq = builder.Configuration.GetConnectionString("RabbitMq")
               ?? Environment.GetEnvironmentVariable("CONNECTIONSTRINGS__RABBITMQ")
               ?? "amqp://guest:guest@localhost:5672";

// Services
builder.Services.AddGrpc(o => { o.EnableDetailedErrors = true; }).AddJsonTranscoding();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddGrpcReflection();

builder.Services.AddDbContext<SaleDbContext>(opt =>
    opt.UseNpgsql(postgres));

builder.Services.AddScoped<IOrderRepository, OrderRepository>();

builder.Services.AddMassTransit(x =>
{
    x.SetKebabCaseEndpointNameFormatter();
    x.UsingRabbitMq((context, cfg) => { cfg.Host(new Uri(rabbitmq)); });
});

var app = builder.Build();

app.UseSwagger();

// Migrate DB (best effort)
try
{
    using var scope = app.Services.CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<SaleDbContext>();
    await db.Database.MigrateAsync();
}
catch
{
    // ignore in bootstrap
}

// Endpoints
app.MapGrpcService<SaleService>();
app.MapGrpcReflectionService();

// Health + root info
app.MapGet("/", () => new
{
    name = "Sale.API",
    grpc = "/sale.v1.Sale/",
    http = "/api/sale/*"
});

await app.RunAsync();
