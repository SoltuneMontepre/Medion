# Medion Microservices Backend

A modern, high-performance microservices solution built on **.NET 10** and **C# 14**, featuring gRPC for internal communication, JSON transcoding for REST APIs, and a YARP reverse proxy gateway.

## 🏗️ Architecture Overview

```text
┌─────────────────────────────────────────────────────────┐
│                    Angular Frontend                      │
└────────────────────┬────────────────────────────────────┘
                     │ HTTP/JSON
┌────────────────────▼────────────────────────────────────┐
│            YARP Reverse Proxy Gateway (8080)             │
│           Routes /api/{service}/* → Services             │
└──┬────┬────┬───────┬───────┬─────────┬────────────────────┘
   │    │    │       │       │         │
   │gRPC+Transcoding (HTTP2) to Services:
   │
   ├─▶ Sale.API (5101) ─────────┐
   │                            │
   ├─▶ Approval.API (5102)      │ PostgreSQL (per-service)
   │                            │
   ├─▶ Payroll.API (5103)       │
   │                            │
   ├─▶ Inventory.API (5104)     │
   │                            │ RabbitMQ (Message Bus)
   ├─▶ Manufacture.API (5105)   │
   │                            │
   ├─▶ Identity.API (5106)      │
   │                            │
   └──────────────────────────┘
```

## 📦 Tech Stack

| Component         | Tech                    | Version      |
| ----------------- | ----------------------- | ------------ |
| **Runtime**       | .NET                    | 10.0         |
| **Language**      | C#                      | 14 (preview) |
| **Communication** | gRPC + JSON Transcoding | 2.71.0       |
| **API Gateway**   | YARP                    | 2.1.0        |
| **Message Bus**   | MassTransit + RabbitMQ  | 8.3.1 / 3.13 |
| **Database**      | PostgreSQL              | 16           |
| **ORM**           | Entity Framework Core   | 9.0.0        |
| **gRPC IDL**      | Protocol Buffers        | sale.v1      |

## ⚡ Quick Start

### Prerequisites

- **.NET 10 SDK** (download from [dotnet.microsoft.com](https://dotnet.microsoft.com))
- **Docker & Docker Compose**
- **Git**

### Clone & Build

```bash
cd backend
dotnet restore
dotnet build
```

### Run Locally (Without Containers)

#### Start Services Individually

```bash
# Terminal 1: Sale Service
dotnet run --project Services/Sale/API/Sale.API.csproj

# Terminal 2: Another service
dotnet run --project Services/Approval/API/Approval.API.csproj

# Terminal 3: Gateway
dotnet run --project Gateway/YarpGateway.csproj
```

**Note:** Local runs require PostgreSQL and RabbitMQ running. Use docker compose for infrastructure.

#### Run Everything with Docker Compose

```bash
docker compose up -d --build

# Check logs
docker compose logs -f gateway
docker compose logs -f sale.api

# Stop all
docker compose down -v
```

### Verify Installation

```bash
# Health check via Gateway
curl http://localhost:8080/

# Call Sale service via JSON transcoding
curl -X POST http://localhost:8080/api/sale/orders \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": "cust-123",
    "items": [
      {"sku": "SKU001", "quantity": 2, "unitPrice": 19.99}
    ]
  }'

# Call Sale service via gRPC (if grpcurl installed)
grpcurl -plaintext -d '{"id":"order-123"}' \
  localhost:5101 sale.v1.Sale.GetOrder
```

## 📂 Project Structure

```text
backend/
├── Protos/
│   └── sale/v1/
│       └── sale.proto          # gRPC service definition + JSON HTTP rules
├── Gateway/
│   ├── YarpGateway.csproj      # YARP reverse proxy
│   ├── Program.cs              # Routing config
│   └── appsettings.json        # Route definitions
├── Services/
│   ├── Sale/
│   │   ├── Domain/             # Entities, value objects
│   │   ├── Application/        # Use cases, abstractions
│   │   ├── Infrastructure/     # EF DbContext, repositories
│   │   └── API/                # gRPC service, Program.cs
│   ├── Approval/
│   ├── Payroll/
│   ├── Inventory/
│   ├── Manufacture/
│   └── Identity/
├── ServiceDefaults/            # Shared extension methods
├── AppHost/                    # Aspire orchestration
├── Directory.Build.props       # Central lang/framework settings
├── Directory.Packages.props    # Centralized package versions
├── App.slnx                    # Minimal solution format
└── docker-compose.yaml         # Local dev environment
```

### Service Anatomy (Clean Architecture)

Each service follows a **4-layer Clean Architecture**:

1. **Domain**: Core entities (e.g., `Order`), business logic, no external deps.

    - Example: [Services/Sale/Domain/Entities/Order.cs](Services/Sale/Domain/Entities/Order.cs)

2. **Application**: Use cases, DTOs, abstractions (e.g., `IOrderRepository`).

    - Example: [Services/Sale/Application/Abstractions/IOrderRepository.cs](Services/Sale/Application/Abstractions/IOrderRepository.cs)

3. **Infrastructure**: EF DbContext, repositories, external service integrations.

    - Example: [Services/Sale/Infrastructure/Data/SaleDbContext.cs](Services/Sale/Infrastructure/Data/SaleDbContext.cs)

4. **API**: gRPC service implementation, HTTP endpoints, DI wiring.
    - Example: [Services/Sale/API/Grpc/SaleService.cs](Services/Sale/API/Grpc/SaleService.cs)

## 🔄 Communication Patterns

### gRPC (Internal Service-to-Service)

Services communicate via **gRPC** for low-latency, binary-safe calls:

```csharp
// Sale.API listens on HTTP2
// Other services can call:
var client = new Sale.SaleClient(channel);
var order = await client.GetOrderAsync(new GetOrderRequest { Id = "123" });
```

**Proto Definition** ([Protos/sale/v1/sale.proto](Protos/sale/v1/sale.proto)):

```protobuf
service Sale {
  rpc GetOrder (GetOrderRequest) returns (OrderReply) {
    option (google.api.http) = {
      get: "/api/sale/orders/{id}"
    };
  }
}
```

### JSON Transcoding (Client → Gateway)

Clients call REST endpoints; **gRPC-JSON Transcoding** converts to gRPC internally:

```bash
# Client calls REST via Gateway
POST /api/sale/orders
Content-Type: application/json

{ "customerId": "cust-123", "items": [...] }
```

**Gateway routing** ([Gateway/appsettings.json](Gateway/appsettings.json)):

```json
{
    "Routes": [
        { "RouteId": "sale", "Match": { "Path": "/api/sale/{**catch-all}" } }
    ],
    "Clusters": {
        "sale": {
            "Destinations": { "d1": { "Address": "http://sale.api:8080" } }
        }
    }
}
```

### Async Messaging (Event Integration)

Services publish/subscribe via **MassTransit + RabbitMQ**:

```csharp
// In Sale.API Program.cs
builder.Services.AddMassTransit(x =>
{
    x.UsingRabbitMq((context, cfg) =>
    {
        cfg.Host(new Uri(rabbitmqUri));
    });
});
```

**Example**: Sale service publishes `OrderCreated` event → Inventory service listens and reserves stock.

## 🗄️ Database & Persistence

### Database-per-Service Pattern

Each service has its **own PostgreSQL database**:

| Service     | Database      | Port | Host      |
| ----------- | ------------- | ---- | --------- |
| Sale        | `sale`        | 5433 | localhost |
| Approval    | `approval`    | 5434 | localhost |
| Payroll     | `payroll`     | 5435 | localhost |
| Inventory   | `inventory`   | 5436 | localhost |
| Manufacture | `manufacture` | 5437 | localhost |
| Identity    | `identity`    | 5438 | localhost |

### Entity Framework Core

Services use **EF Core 9.0** with Npgsql:

```csharp
// SaleDbContext auto-migrates on startup
builder.Services.AddDbContext<SaleDbContext>(opt =>
    opt.UseNpgsql(connectionString));

using var scope = app.Services.CreateScope();
var db = scope.ServiceProvider.GetRequiredService<SaleDbContext>();
await db.Database.MigrateAsync();
```

**Migrations** (local development):

```bash
# From Services/Sale/API/
dotnet ef migrations add InitialCreate --project ../Infrastructure/
dotnet ef database update
```

## 🚀 Development Workflow

### Adding a New Service

1. **Create folder structure:**

    ```bash
    mkdir -p Services/YourService/{Domain,Application,Infrastructure,API}
    ```

2. **Create .csproj files** (Domain → Application → Infrastructure → API layers).

3. **Define domain entities** in `Domain/Entities/`.

4. **Add abstractions** in `Application/Abstractions/` (e.g., `IYourRepository`).

5. **Implement EF DbContext** in `Infrastructure/Data/YourDbContext.cs`.

6. **Create gRPC service:**

    - Add `.proto` file to [Protos/yourservice/v1/yourservice.proto](Protos/yourservice/v1/yourservice.proto).
    - Implement `YourService : YourServiceBase` in `API/Grpc/YourService.cs`.

7. **Wire Program.cs** (see [Services/Sale/API/Program.cs](Services/Sale/API/Program.cs) for template).

8. **Register in [App.slnx](App.slnx)**.

9. **Add Docker compose entries** and update YARP routes.

### C# 14 Features (Enforced)

- **Primary Constructors** in domain entities and services:

    ```csharp
    public sealed class Order(string id, string customerId)
    {
        public string Id { get; init; } = id;
    }
    ```

- **Collection Expressions** for initializers:

    ```csharp
    public List<OrderItem> Items { get; init; } = [];
    ```

- **File-scoped Namespaces** (no curly braces):

    ```csharp
    namespace Services.Sale.Domain.Entities;
    ```

- **field Keyword** for private fields (if needed).

## 📋 Commands Reference

### Build & Run

```bash
# Restore packages
dotnet restore

# Build solution
dotnet build

# Build single project
dotnet build Services/Sale/API/Sale.API.csproj

# Run with live reload
dotnet watch run --project Services/Sale/API/Sale.API.csproj
```

### Docker Compose

```bash
# Start all (build + containers)
docker compose up -d --build

# View logs
docker compose logs -f gateway
docker compose logs sale.api

# Stop and remove
docker compose down

# Cleanup volumes (reset databases)
docker compose down -v
```

### Testing gRPC

```bash
# Install grpcurl (if not present)
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

# List services (requires reflection)
grpcurl -plaintext localhost:5101 list

# Call RPC
grpcurl -plaintext -d '{"id":"order-123"}' \
  localhost:5101 sale.v1.Sale.GetOrder
```

### Entity Framework Migrations

```bash
# Create migration (from API project folder)
dotnet ef migrations add MigrationName \
  --project ../Infrastructure/YourService.Infrastructure.csproj \
  --startup-project .

# Apply migration
dotnet ef database update

# Remove last migration
dotnet ef migrations remove
```

## 🔧 Configuration

### Environment Variables

Services read from environment or `appsettings.json`:

```bash
export ConnectionStrings__Postgres="Host=localhost;Port=5432;..."
export ConnectionStrings__RabbitMq="amqp://guest:guest@localhost:5672"
export ASPNETCORE_ENVIRONMENT="Development"
```

### Central Package Management

All NuGet versions are defined in [Directory.Packages.props](Directory.Packages.props):

```xml
<ItemGroup Label="EntityFramework + Npgsql">
  <PackageVersion Include="Microsoft.EntityFrameworkCore" Version="9.0.0" />
  <PackageVersion Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="9.0.2" />
</ItemGroup>
```

Services reference without version:

```xml
<PackageReference Include="Microsoft.EntityFrameworkCore" />
```

## 📖 Key Files to Review

| File                                                         | Purpose                                   |
| ------------------------------------------------------------ | ----------------------------------------- |
| [App.slnx](App.slnx)                                         | Solution definition (minimal format)      |
| [Directory.Build.props](Directory.Build.props)               | Language, framework, shared properties    |
| [Directory.Packages.props](Directory.Packages.props)         | Centralized NuGet versions                |
| [docker-compose.yaml](docker-compose.yaml)                   | Dev environment (services, DBs, RabbitMQ) |
| [Protos/sale/v1/sale.proto](Protos/sale/v1/sale.proto)       | gRPC service + HTTP rules example         |
| [Gateway/appsettings.json](Gateway/appsettings.json)         | YARP routing rules                        |
| [Services/Sale/API/Program.cs](Services/Sale/API/Program.cs) | Reference Program.cs template             |

## 🎯 Common Tasks

### Running a Single Service with Local DB

```bash
# Ensure Postgres + RabbitMQ are running
docker compose up -d postgres rabbitmq

# Run Sale service
dotnet run --project Services/Sale/API/Sale.API.csproj

# In another terminal, test REST endpoint
curl http://localhost:5101/
```

### Debugging

**VS Code:**

- Open the workspace: `code .`
- Set breakpoints in any .cs file
- Press F5 → Select ".NET 10" environment
- Attach to the running dotnet process

**Visual Studio:**

- Open `App.slnx`
- Build solution (Ctrl+Shift+B)
- Set startup project: Gateway or any API
- Press F5 to debug

### Viewing gRPC Service Metadata

```bash
# Enable reflection in any API's Program.cs:
app.MapGrpcReflectionService();

# List services:
grpcurl -plaintext localhost:5101 list

# List methods:
grpcurl -plaintext localhost:5101 sale.v1.Sale

# Describe method:
grpcurl -plaintext localhost:5101 describe sale.v1.Sale.GetOrder
```

## 🔐 Production Considerations

- **Enable HTTPS/TLS** in production (Kestrel config, certificates).
- **Secure RabbitMQ** with credentials and AMQPS.
- **Use managed PostgreSQL** (AWS RDS, Azure Database, etc.) instead of containers.
- **Enable observability**: OpenTelemetry for tracing, logging, metrics.
- **Implement service discovery** (e.g., Consul, Kubernetes DNS).
- **Add authentication/authorization** (OAuth2, JWT) in Gateway + Identity service.

## 📞 Support & Troubleshooting

### Build fails: "google/api/annotations.proto not found"

Ensure `Grpc.Tools` and `Google.Api.CommonProtos` are referenced in the API .csproj.

### Services can't connect to RabbitMQ/PostgreSQL

Check docker compose is running:

```bash
docker compose ps
```

Verify connection strings in [docker-compose.yaml](docker-compose.yaml) match appsettings.json.

### Proto changes not reflected in generated code

Run:

```bash
dotnet clean Services/Sale/API/
dotnet build Services/Sale/API/
```

### "Address already in use" when running locally

Kill the process on the port:

```bash
lsof -i :5101  # Find process
kill -9 <PID>
```

## 📚 Resources

- [gRPC Documentation](https://grpc.io/docs/languages/csharp/)
- [YARP (Reverse Proxy)](https://microsoft.github.io/reverse-proxy/)
- [MassTransit](https://masstransit.io/)
- [Entity Framework Core](https://learn.microsoft.com/en-us/ef/core/)
- [C# 14 Features](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/functional/top-level-statements)

---

**Last Updated:** January 10, 2026
**Maintainers:** Medion Team
