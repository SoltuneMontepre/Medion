package config

import (
	"fmt"
	"net/http"
	"os"
	"time"

	"backend/internal/controller"
	"backend/internal/converter"
	"backend/internal/database"
	"backend/internal/dto"
	"backend/internal/middleware"
	"backend/internal/repository"
	"backend/internal/security"
	"backend/internal/service"

	"github.com/getkin/kin-openapi/openapi3"
	"github.com/go-fuego/fuego"
	cache "github.com/patrickmn/go-cache"
)

func BuildServer() (*fuego.Server, error) {
	db, err := database.Open(database.Config{})
	if err != nil {
		return nil, fmt.Errorf("open database: %w", err)
	}
	if err := database.AutoMigrate(db); err != nil {
		return nil, fmt.Errorf("auto migrate: %w", err)
	}

	jwtManager, err := security.NewJWTManagerFromEnv()
	if err != nil {
		return nil, fmt.Errorf("init jwt: %w", err)
	}

	blacklist := cache.New(30*time.Minute, 1*time.Minute)

	userRepo := repository.NewUserRepository(db)
	conv := converter.NewConverter()
	authService := service.NewAuthService(userRepo, jwtManager, blacklist, conv)
	authController := controller.NewAuthController(authService)
	authGuard := middleware.AccessTokenGuard(jwtManager, blacklist)

	addr := os.Getenv("APP_ADDR")
	if addr == "" {
		addr = ":9999"
	}

	server := fuego.NewServer(
		fuego.WithAddr(addr),
		fuego.WithErrorSerializer(dto.ErrorSerializer),
		fuego.WithDisallowUnknownFields(true),
	)

	// Configure OpenAPI/Swagger
	serverURL := os.Getenv("SERVER_URL")
	if serverURL == "" {
		serverURL = "http://localhost" + addr
	}
	server.OpenAPI.Config.DisableDefaultServer = true
	// Add servers to the OpenAPI description
	desc := server.OpenAPI.Description()
	desc.Servers = append(desc.Servers, &openapi3.Server{
		URL:         serverURL,
		Description: "API Server",
	})

	RegisterRoutes(server, authController, func(next http.Handler) http.Handler {
		return authGuard(next)
	})
	return server, nil
}
