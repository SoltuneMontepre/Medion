# MES Medion

Manufacturing Execution System (MES) with GMP (Good Manufacturing Practice) support — traceability, auditability, and validation.

## Overview

- **Backend**: Go API (Fuego, GORM, PostgreSQL) — auth, business logic, REST + OpenAPI/Swagger.
- **Frontend**: Flutter desktop app (Windows primary) — go_router, Riverpod, Dio; top-bar navigation and modular layout.

## Prerequisites

| Component   | Requirement |
|------------|-------------|
| **Backend** | [Go 1.23+](https://go.dev/dl/), [PostgreSQL 12+](https://www.postgresql.org/download/) |
| **Frontend** | [Flutter SDK](https://docs.flutter.dev/get-started/install) (SDK ^3.11) — for Windows desktop |

Verify:

```bash
go version
psql --version
flutter doctor
```

## Development — How to run

### 1. Clone and enter repo

```bash
git clone https://github.com/SoltuneMontepre/Medion.git
cd Medion
```

### 2. Backend (Go API)

```bash
cd backend
go mod download
cp .env.example .env
# Edit .env: set DATABASE_DSN, JWT_SECRET (see backend/.env.example)
```

Ensure PostgreSQL is running and the database exists (e.g. `createdb medion`). GORM will auto-migrate tables on startup.

```bash
go run ./cmd/api
```

- API: **http://localhost:9999**
- Swagger UI: **http://localhost:9999/swagger**
- OpenAPI JSON: **http://localhost:9999/openapi.json**

Default `APP_ADDR` is `:9999`; override with `APP_ADDR` in `.env`.

### 3. Frontend (Flutter)

In a separate terminal:

```bash
cd Medion/frontend_flutter
flutter pub get
flutter run -d windows
```

For Chrome (web):

```bash
flutter run -d chrome
```

Point the app’s API base URL to `http://localhost:9999` (or your backend) as configured in the Flutter app (e.g. env or config).

---

## Project layout

```
Medion/
├── backend/           # Go API (Fuego, GORM, PostgreSQL, JWT auth)
│   ├── cmd/api/       # Entrypoint
│   ├── internal/      # config, controller, service, repository, model, dto, middleware
│   └── .env.example   # Copy to .env and fill
├── frontend_flutter/  # Flutter desktop (go_router, Riverpod, Dio)
│   └── lib/           # core/, features/, shared/
└── README.md          # This file
```

## Tech stack

| Layer    | Stack |
|----------|--------|
| **Frontend** | Flutter, go_router, Riverpod, Dio |
| **Backend**  | Go, Fuego, GORM, PostgreSQL, JWT (Argon2id, cookie-based refresh) |
| **DevOps**   | (Add CI/CD, Docker, etc. as needed) |

## Docs

- **Backend**: [backend/README.md](backend/README.md) — API endpoints, auth flow, setup, OpenAPI.
- **Frontend**: [frontend_flutter/README.md](frontend_flutter/README.md) — Flutter getting started.

## Contributing

Open issues and PRs on the GitHub repo. For backend changes, follow GMP rules (audit fields, context, validation, structured errors); for frontend, follow the shell/navigation and routing conventions in the project rules.
