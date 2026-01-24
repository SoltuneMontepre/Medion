# Medion Backend – Onboarding

Tài liệu này giúp dev mới hiểu nhanh kiến trúc và cách chạy dự án.

## Kiến trúc tóm tắt

- Orchestrator dùng .NET Aspire AppHost: khởi chạy Postgres, RabbitMQ và các service, xem [AppHost/AppHost.cs#L3-L48](AppHost/AppHost.cs#L3-L48).
- API Gateway dùng YARP, load config từ appsettings, xem [Gateway/Program.cs#L4-L82](Gateway/Program.cs#L4-L82) và [Gateway/appsettings.json](Gateway/appsettings.json).
- Các domain service tuân theo clean architecture: `Domain` + `Application` + `Infrastructure` + `API` (Sales, Approval, Payroll, Inventory, Manufacture, Identity). Shared libs: `ServiceDefaults` (health, OpenTelemetry, service discovery) và `SharedStorage` (S3).
- gRPC contracts đặt tại `Protos/` và build qua `Grpc.Tools`.

## Yêu cầu môi trường

- .NET SDK 10 (preview) và workloads Aspire: `dotnet workload install aspire`.
- Docker + Docker Compose (cho Postgres, RabbitMQ nếu không chạy bằng Aspire host).
- Make sure `OTEL_EXPORTER_OTLP_ENDPOINT` có giá trị khi cần gửi telemetry ra OTLP.

## Chạy nhanh toàn bộ stack

1) `dotnet restore` ở thư mục backend.
2) Khởi chạy bằng Aspire: `dotnet run --project AppHost/AppHost.csproj`.
   - AppHost sẽ spin up Postgres + RabbitMQ, rồi chạy từng service và Gateway.
3) Gateway mặc định lắng nghe (qua Aspire) và expose swagger tại `http://localhost:<gateway-port>/swagger`.
4) Dừng bằng Ctrl+C.

## Chạy một service riêng lẻ

- Ví dụ Sale API: `dotnet run --project Services/Sale/API/Sale.API.csproj --urls http://localhost:8080`.
- Để gateway forward đến instance tự chạy, chỉnh `Gateway/appsettings.json` cho đúng `Address` hoặc chạy qua Aspire để tự resolve.

## Routing qua Gateway (mặc định)

- Sale: `/api/sale/*` → `sale.api:8080`
- Approval: `/api/approval/*` → `approval.api:8080`
- Payroll: `/api/payroll/*` → `payroll.api:8080`
- Inventory: `/api/inventory/*` → `inventory.api:8080`
- Manufacture: `/api/manufacture/*` → `manufacture.api:8080`
- Identity: `/api/identity/*` → `identity.api:8080`
- Swagger gộp: `/swagger` và từng service tại `/swagger-docs/{service}/v1/swagger.json`.

## Health check và observability

- Health: `/health`, Liveness: `/alive` (dev-only) từ [ServiceDefaults/Extensions.cs#L58-L74](ServiceDefaults/Extensions.cs#L58-L74).
- OpenTelemetry tích hợp sẵn HTTP, ASP.NET Core, runtime; cấu hình exporter qua biến môi trường `OTEL_EXPORTER_OTLP_ENDPOINT`.

## Quy ước code nhanh

- Ngôn ngữ C#, `net10.0`, `LangVersion` preview, nullable bật, implicit usings bật ([Directory.Build.props#L3-L23](Directory.Build.props#L3-L23)).
- Quản lý version NuGet tập trung qua `Directory.Packages.props`.
- Mỗi service nên tham chiếu `ServiceDefaults` để có health, discovery, resilience, OTel.
- Thêm proto mới vào `Protos/*` và tham chiếu qua `GrpcProtoRoot` trong build props.

## Kiểm thử

- Chạy toàn bộ test: `dotnet test Backend.slnx` (hoặc `dotnet test` tại repo root nếu có solution file `.sln`).

## Troubleshooting nhanh

- Lỗi không tìm thấy Aspire workload: chạy `dotnet workload install aspire` hoặc update `PATH` sau khi cài SDK.
- Cổng trùng khi chạy lẻ service: override `--urls` và cập nhật route gateway tương ứng.
- Nếu telemetry không gửi được: kiểm tra biến `OTEL_EXPORTER_OTLP_ENDPOINT` và outbound network.

## Tài liệu thêm

- Aspire docs: <https://learn.microsoft.com/dotnet/aspire/overview>
- YARP docs: <https://microsoft.github.io/reverse-proxy/>
