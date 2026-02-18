using Projects;

var builder = DistributedApplication.CreateBuilder(args);

// Infrastructure - RabbitMQ (shared)
var rabbitmq = builder.AddRabbitMQ("rabbitmq")
    .WithDataVolume();

// Identity provider - Keycloak
var keycloak = builder.AddContainer("keycloak", "quay.io/keycloak/keycloak", "25.0.6")
    .WithArgs("start-dev")
    .WithEnvironment("KEYCLOAK_ADMIN", "admin")
    .WithEnvironment("KEYCLOAK_ADMIN_PASSWORD", "admin")
    .WithEndpoint(targetPort: 8080, port: 8080, scheme: "http", name: "http")
    .WithVolume("keycloak-data", "/opt/keycloak/data");

// PostgreSQL - Single container, multiple databases
var postgres = builder.AddPostgres("postgres")
    .WithDataVolume();

var salePostgres = postgres.AddDatabase("postgres-sale");
var approvalPostgres = postgres.AddDatabase("postgres-approval");
var payrollPostgres = postgres.AddDatabase("postgres-payroll");
var inventoryPostgres = postgres.AddDatabase("postgres-inventory");
var manufacturePostgres = postgres.AddDatabase("postgres-manufacture");
var securityPostgres = postgres.AddDatabase("postgres-security");

// MongoDB - For Audit Logs
var mongodb = builder.AddMongoDB("mongodb")
    .WithImageTag("6.0")
    .WithDataVolume("medion-mongo-data-v4")
    .WithArgs("--wiredTigerCacheSizeGB", "0.25");

// Services
var securityApi = builder.AddProject<Security_API>("security-api")
    .WithReference(securityPostgres)
    .WithReference(rabbitmq);

var saleApi = builder.AddProject<Sale_API>("sale-api")
    .WithReference(salePostgres)
    .WithReference(rabbitmq)
    .WithReference(securityApi);  // gRPC dependency for signing

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

// Audit API - consumes events and writes to MongoDB
var auditApi = builder.AddProject<Audit_API>("audit-api")
    .WithReference(mongodb)
    .WithReference(rabbitmq);

// Gateway
builder.AddProject<YarpGateway>("gateway")
    .WithReference(saleApi)
    .WithReference(approvalApi)
    .WithReference(payrollApi)
    .WithReference(inventoryApi)
    .WithReference(manufactureApi)
    .WithReference(securityApi)
    .WithReference(auditApi);

var app = builder.Build();

await app.RunAsync();
