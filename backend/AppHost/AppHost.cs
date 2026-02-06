using Projects;

var builder = DistributedApplication.CreateBuilder(args);

// Infrastructure - RabbitMQ (shared)
var rabbitmq = builder.AddRabbitMQ("rabbitmq")
    .WithDataVolume();

// PostgreSQL - One per service
var salePostgres = builder.AddPostgres("postgres-sale")
    .WithDataVolume();

var approvalPostgres = builder.AddPostgres("postgres-approval")
    .WithDataVolume();

var payrollPostgres = builder.AddPostgres("postgres-payroll")
    .WithDataVolume();

var inventoryPostgres = builder.AddPostgres("postgres-inventory")
    .WithDataVolume();

var manufacturePostgres = builder.AddPostgres("postgres-manufacture")
    .WithDataVolume();

var identityPostgres = builder.AddPostgres("postgres-identity")
    .WithDataVolume();

// Services
var saleApi = builder.AddProject<Sale_API>("sale-api")
    .WithReference(salePostgres)
    .WithReference(rabbitmq);

var approvalApi = builder.AddProject<Approval_API>("approval-api")
    .WithReference(approvalPostgres)
    .WithReference(rabbitmq);

var payrollApi = builder.AddProject<Payroll_API>("payroll-api")
    .WithReference(payrollPostgres)
    .WithReference(rabbitmq);

var inventoryApi = builder.AddProject<Inventory_API>("inventory-api")
    .WithReference(inventoryPostgres)
    .WithReference(rabbitmq);

var manufactureApi = builder.AddProject<Manufacture_API>("manufacture-api")
    .WithReference(manufacturePostgres)
    .WithReference(rabbitmq);

var identityApi = builder.AddProject<Identity_API>("identity-api")
    .WithReference(identityPostgres)
    .WithReference(rabbitmq);

// Gateway
builder.AddProject<YarpGateway>("gateway")
    .WithReference(saleApi)
    .WithReference(approvalApi)
    .WithReference(payrollApi)
    .WithReference(inventoryApi)
    .WithReference(manufactureApi)
    .WithReference(identityApi);

var app = builder.Build();

await app.RunAsync();
