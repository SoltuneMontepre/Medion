# Medion Backend - Complete Authentication System

## Overview

Hệ thống Authentication hoàn chỉnh sử dụng **Fuego Framework**, **GORM + PostgreSQL**, **Argon2id**, **JWT**, và **go-cache** để quản lý token blacklist.

## Kiến Trúc & Thiết Kế

### 1. Tech Stack
- **Framework**: Fuego (OpenAPI auto-generation, net/http compatible)
- **ORM**: GORM + PostgreSQL driver
- **Password Hashing**: Argon2id (`golang.org/x/crypto/argon2`)
- **JWT**: `github.com/golang-jwt/jwt/v5`
- **Caching**: `github.com/patrickmn/go-cache` (in-memory token blacklist)
- **Go Version**: 1.23+

### 2. API Endpoints

#### POST /register
Đăng ký tài khoản mới.

**Request:**
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "SecurePass123!"
}
```

**Response (201 Created):**
```json
{
  "status": "success",
  "code": 201,
  "message": "register success",
  "data": {
    "accessToken": "eyJhbGc...",
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "username": "john_doe",
      "email": "john@example.com"
    }
  }
}
```

**Cookies Set:**
- `refresh_token` (HttpOnly, Secure, SameSite=Lax, Path=/refresh)

---

#### POST /login
Đăng nhập với email và password.

**Request:**
```json
{
  "email": "john@example.com",
  "password": "SecurePass123!"
}
```

**Response (200 OK):**
```json
{
  "status": "success",
  "code": 200,
  "message": "login success",
  "data": {
    "accessToken": "eyJhbGc...",
    "user": {...}
  }
}
```

**Cookies Set:**
- `refresh_token` (same as register)

---

#### POST /refresh
Lấy access token mới từ refresh token.

**Headers:**
- `Cookie: refresh_token=<refresh_token>`

**Response (200 OK):**
```json
{
  "status": "success",
  "code": 200,
  "message": "refresh success",
  "data": {
    "accessToken": "eyJhbGc... (new)",
    "user": {...}
  }
}
```

**Cookies Set:**
- `refresh_token` (rotate to new token)

---

#### POST /logout
Đăng xuất (yêu cầu Access Token).

**Headers:**
- `Authorization: Bearer <access_token>`

**Response (200 OK):**
```json
{
  "status": "success",
  "code": 200,
  "message": "logout success",
  "data": {
    "loggedOut": true
  }
}
```

**Cookies Set:**
- `refresh_token` (deleted/expired)

---

### 3. Lưu Ý Về Response Envelope

Mọi response (thành công hay lỗi) đều được bọc trong struct với cấu trúc:
```go
{
  "status": "success" | "error",
  "code": <HTTP status code>,
  "message": "...",
  "data": <actual data or null>
}
```

---

### 4. Kiến Trúc Layer

#### DTO (`internal/dto/`)
- `envelope.go`: Response wrapper, error serializer
- `auth.go`: Request/response DTOs (RegisterRequest, LoginRequest, AuthData, etc.)
- `error.go`: Custom `AppError` type với `StatusCode()` method
- `context.go`: Context keys

#### Security (`internal/security/`)
- `password.go`: Argon2id hashing/verification (64MB memory, t=3, p=2)
- `jwt.go`: JWT generation, parsing, token refresh logic (access TTL: 15m, refresh TTL: 7d)
- `cookie.go`: HTTP Cookie builder với flags HttpOnly, Secure, SameSite=Lax

#### Repository (`internal/repository/`)
- `base_repository.go`: Generic `Repository[T]` CRUD pattern
  - `FindByID(ctx, id)`, `Create(ctx, entity)`, `Update(ctx, entity)`, `Delete(ctx, id)`
- `UserRepository`: Extends base, adds `ExistsByEmail()`, `ExistsByUsername()`, `FindByEmail()`

#### Service (`internal/service/`)
- `auth_service.go`: Business logic
  - `Register()`: xác thực input, hash password, tạo user, generate token pair
  - `Login()`: tìm user, verify password, generate tokens
  - `Refresh()`: parse refresh token, generate access token mới
  - `Logout()`: thêm access token vào blacklist cache

#### Middleware (`internal/middleware/`)
- `auth_middleware.go`: `AccessTokenGuard` middleware
  - Kiểm tra `Authorization: Bearer <token>` header
  - Kiểm tra token có nằm trong blacklist (logout)
  - Validate JWT signature & expiry
  - Inject token vào context

#### Controller (`internal/controller/`)
- `auth_controller.go`: Fuego handlers
  - `Register()`, `Login()`, `Refresh()`, `Logout()`
  - Tự động validation via `validate` tags (Fuego built-in)
  - Set cookies + Access Token trong JSON response

#### Config (`internal/config/`)
- `wire.go`: Dependency injection
  - Kết nối DB, init JWT manager, cache, repository, service, controller
  - Cấu hình server & error serializer
- `route.go`: Register routes với Fuego

#### Database (`internal/database/`)
- `database.go`: OpenConnection, AutoMigrate (User model)

---

### 5. Argument2id Configuration

```go
const (
  argon2Memory      = 64 * 1024      // 64 MB memory
  argon2Iterations  = 3              // 3 passes
  argon2Parallelism = 2              // 2 parallel threads
  argon2SaltLength  = 16             // 16 bytes salt
  argon2KeyLength   = 32             // 32 bytes output hash
)
```

Format: `$argon2id$v=19$m=65536,t=3,p=2$<b64_salt>$<b64_hash>`

---

### 6. Token Blacklist

- In-memory cache: `github.com/patrickmn/go-cache`
- TTL = remaining lifetime của token (hoặc 1 min nếu không tính được)
- Cleanup background: 1 minute interval
- **Note**: Cho production, cần migrate sang Redis hoặc database untuk distributed systems

---

### 7. Setup & Run

#### Prerequisites
- PostgreSQL 12+
- Go 1.23+

#### Install Dependencies
```bash
go mod download
```

#### Environment
```bash
cp .env.example .env
# Edit .env: điền DATABASE_DSN, JWT_SECRET
```

#### Database
```bash
# GORM AutoMigrate sẽ tự tạo bảng users khi server start
# Hoặc CLI: psql -U user -d medion -f schema.sql (nếu có)
```

#### Build
```bash
go build -o tmp/main ./cmd/api
```

#### Run
```bash
./tmp/main
# Server listens on http://localhost:9999 (hoặc APP_ADDR trong .env)
```

#### Test
```bash
# Register
curl -X POST http://localhost:9999/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "TestPassword123!"
  }'

# Login
curl -X POST http://localhost:9999/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPassword123!"
  }'

# Refresh (fetch refresh_token từ Set-Cookie header)
curl -X POST http://localhost:9999/refresh \
  -H "Cookie: refresh_token=<TOKEN>"

# Logout (fetch access_token từ register/login response)
curl -X POST http://localhost:9999/logout \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

---

### 8. OpenAPI Documentation

Server tự động sinh OpenAPI spec tại:
- **Swagger UI**: http://localhost:9999/swagger
- **JSON Spec**: http://localhost:9999/openapi.json
- **File**: `doc/openapi.json`

---

### 9. Error Handling

All errors follow envelope format với custom status codes (1000-1999):

| Code | Message | HTTP |
|------|---------|------|
| 1001 | Fields required | 400 |
| 1002 | Email exists | 409 |
| 1003 | Username exists | 409 |
| 1004 | Email/password required | 400 |
| 1005-1006 | Invalid credentials | 401 |
| 1007 | Invalid refresh token | 401 |
| 1008 | User not found | 401 |
| 1010 | Refresh token missing | 401 |
| 1011 | Access token missing | 401 |
| 1500-1509 | Internal errors | 500 |

---

### 10. Security Best Practices Applied

✅ **Password Hashing**: Argon2id (resistant to GPU/ASIC attacks)
✅ **JWT**: Signed with HS256, includes expiry & issued-at timestamps
✅ **Token Refresh**: Separate refresh token with longer TTL, rotated on each use
✅ **Cookie Security**: HttpOnly (XSS protection), Secure (HTTPS), SameSite=Lax (CSRF protection)
✅ **Token Blacklist**: Logout immediately revokes access token
✅ **Context Injection**: Access token injected safely via middleware
✅ **Error Messages**: Generic messages to prevent user enumeration

---

### 11. Future Improvements

- [ ] Persist token blacklist to Redis (distributed)
- [ ] Add refresh token rotation & revocation tracking
- [ ] Implement rate limiting on login/register
- [ ] Add 2FA support (TOTP, email)
- [ ] Add password reset flow
- [ ] Add user roles & permission system
- [ ] Database migrations tool (goose, flyway, etc.)
- [ ] Test coverage (unit + integration)

---

## Dependency List

```
github.com/go-fuego/fuego    v0.19.0   # Framework
github.com/golang-jwt/jwt    v5.3.0    # JWT
gorm.io/gorm                 v1.25.7   # ORM
gorm.io/driver/postgres      v1.5.7    # Database
golang.org/x/crypto          v0.36.0   # Argon2id
github.com/patrickmn/go-cache v2.1.0   # Cache
github.com/google/uuid       v1.6.0    # UUID v7
```

---

Happy coding! 🔥
