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
	if err := database.SeedDefaultUser(db); err != nil {
		return nil, fmt.Errorf("seed default user: %w", err)
	}
	if err := database.SeedProducts(db); err != nil {
		return nil, fmt.Errorf("seed products: %w", err)
	}

	jwtManager, err := security.NewJWTManagerFromEnv()
	if err != nil {
		return nil, fmt.Errorf("init jwt: %w", err)
	}

	blacklist := cache.New(30*time.Minute, 1*time.Minute)

	userRepo := repository.NewUserRepository(db)
	customerRepo := repository.NewCustomerRepository(db)
	productRepo := repository.NewProductRepository(db)
	orderRepo := repository.NewOrderRepository(db)
	orderItemRepo := repository.NewOrderItemRepository(db)
	conv := converter.NewConverter()
	authService := service.NewAuthService(userRepo, jwtManager, blacklist, conv)
	customerService := service.NewCustomerService(customerRepo, conv)
	productService := service.NewProductService(productRepo, conv)
	orderService := service.NewOrderService(orderRepo, orderItemRepo, customerRepo, productRepo, conv)
	authController := controller.NewAuthController(authService)
	customerController := controller.NewCustomerController(customerService)
	productController := controller.NewProductController(productService)
	orderController := controller.NewOrderController(orderService)
	authGuard := middleware.AccessTokenGuard(jwtManager, blacklist)

	addr := os.Getenv("APP_ADDR")
	if addr == "" {
		addr = ":9999"
	}

	server := fuego.NewServer(
		fuego.WithAddr(addr),
		fuego.WithErrorSerializer(dto.ErrorSerializer),
		fuego.WithDisallowUnknownFields(true),
		fuego.WithCorsMiddleware(corsMiddleware),
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

	RegisterRoutes(server, authController, customerController, productController, orderController, func(next http.Handler) http.Handler {
		return authGuard(next)
	})
	return server, nil
}

// corsMiddleware allows the Flutter frontend (web, desktop, mobile) to call the API.
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		if origin == "" {
			origin = "*"
		}
		w.Header().Set("Access-Control-Allow-Origin", origin)
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		w.Header().Set("Access-Control-Allow-Credentials", "true")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}
