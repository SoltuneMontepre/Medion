using Projects;

var builder = DistributedApplication.CreateBuilder(args);

// Infrastructure
var postgres = builder.AddPostgres("postgres")
    .WithDataVolume();

var rabbitmq = builder.AddRabbitMQ("rabbitmq")
    .WithDataVolume();

// Services
var saleApi = builder.AddProject<Sale_API>("sale-api")
    .WithReference(postgres)
    .WithReference(rabbitmq);

var approvalApi = builder.AddProject<Approval_API>("approval-api")
    .WithReference(postgres)
    .WithReference(rabbitmq);

var payrollApi = builder.AddProject<Payroll_API>("payroll-api")
    .WithReference(postgres)
    .WithReference(rabbitmq);

var inventoryApi = builder.AddProject<Inventory_API>("inventory-api")
    .WithReference(postgres)
    .WithReference(rabbitmq);

var manufactureApi = builder.AddProject<Manufacture_API>("manufacture-api")
    .WithReference(postgres)
    .WithReference(rabbitmq);

var identityApi = builder.AddProject<Identity_API>("identity-api")
    .WithReference(postgres)
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
