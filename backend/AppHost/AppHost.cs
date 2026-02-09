using Projects;

var builder = DistributedApplication.CreateBuilder(args);

// Infrastructure - RabbitMQ (shared)
var rabbitmq = builder.AddRabbitMQ("rabbitmq")
    .WithDataVolume();

// PostgreSQL - Single container, multiple databases
var postgres = builder.AddPostgres("postgres")
    .WithDataVolume();

var salePostgres = postgres.AddDatabase("postgres-sale");
var approvalPostgres = postgres.AddDatabase("postgres-approval");
var payrollPostgres = postgres.AddDatabase("postgres-payroll");
var inventoryPostgres = postgres.AddDatabase("postgres-inventory");
var manufacturePostgres = postgres.AddDatabase("postgres-manufacture");
var identityPostgres = postgres.AddDatabase("postgres-identity");

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
