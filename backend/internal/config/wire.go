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
	if err := database.SeedIngredients(db); err != nil {
		return nil, fmt.Errorf("seed ingredients: %w", err)
	}
	if err := database.SeedOrderSummaryPermissions(db); err != nil {
		return nil, fmt.Errorf("seed order summary permissions: %w", err)
	}
	if err := database.SeedRoles(db); err != nil {
		return nil, fmt.Errorf("seed roles: %w", err)
	}
	if err := database.SeedDefaultUserAdminRole(db); err != nil {
		return nil, fmt.Errorf("seed default user admin role: %w", err)
	}
	if err := database.SeedDefaultCompany(db); err != nil {
		return nil, fmt.Errorf("seed default company: %w", err)
	}
	if err := database.SeedDepartments(db); err != nil {
		return nil, fmt.Errorf("seed departments: %w", err)
	}
	if err := database.SeedDepartmentUsers(db); err != nil {
		return nil, fmt.Errorf("seed department users: %w", err)
	}
	if err := database.SeedInventory(db); err != nil {
		return nil, fmt.Errorf("seed inventory: %w", err)
	}

	jwtManager, err := security.NewJWTManagerFromEnv()
	if err != nil {
		return nil, fmt.Errorf("init jwt: %w", err)
	}

	blacklist := cache.New(30*time.Minute, 1*time.Minute)

	userRepo := repository.NewUserRepository(db)
	companyRepo := repository.NewCompanyRepository(db)
	departmentRepo := repository.NewDepartmentRepository(db)
	inventoryRepo := repository.NewInventoryRepository(db)
	productionPlanRepo := repository.NewProductionPlanRepository(db)
	productionPlanItemRepo := repository.NewProductionPlanItemRepository(db)
	productionOrderRepo := repository.NewProductionOrderRepository(db)
	finishedProductDispatchRepo := repository.NewFinishedProductDispatchRepository(db)
	finishedProductDispatchLineRepo := repository.NewFinishedProductDispatchLineRepository(db)
	customerRepo := repository.NewCustomerRepository(db)
	productRepo := repository.NewProductRepository(db)
	ingredientRepo := repository.NewIngredientRepository(db)
	orderRepo := repository.NewOrderRepository(db)
	orderItemRepo := repository.NewOrderItemRepository(db)
	orderSummaryRepo := repository.NewOrderSummaryRepository(db)
	orderSummaryItemRepo := repository.NewOrderSummaryItemRepository(db)
	roleRepo := repository.NewRoleRepository(db)
	conv := converter.NewConverter()
	authService := service.NewAuthService(userRepo, jwtManager, blacklist, conv)
	userService := service.NewUserService(userRepo, roleRepo, departmentRepo, conv)
	pinService := service.NewPINService(userRepo, jwtManager)
	companyService := service.NewCompanyService(companyRepo, conv)
	departmentService := service.NewDepartmentService(departmentRepo, companyRepo, conv, companyService)
	customerService := service.NewCustomerService(customerRepo, conv)
	productService := service.NewProductService(productRepo, conv)
	ingredientService := service.NewIngredientService(ingredientRepo, conv)
	orderService := service.NewOrderService(orderRepo, orderItemRepo, customerRepo, productRepo, userRepo, orderSummaryRepo, orderSummaryItemRepo, pinService, conv)
	orderSummaryService := service.NewOrderSummaryService(orderSummaryRepo, orderSummaryItemRepo, userRepo, conv)
	authController := controller.NewAuthController(authService, userService)
	pinController := controller.NewPINController(pinService)
	companyController := controller.NewCompanyController(companyService)
	departmentController := controller.NewDepartmentController(departmentService)
	inventoryService := service.NewInventoryService(inventoryRepo, conv)
	inventoryController := controller.NewInventoryController(inventoryService)
	productionPlanService := service.NewProductionPlanService(productionPlanRepo, productionPlanItemRepo, productRepo, userRepo, inventoryRepo, conv)
	productionPlanController := controller.NewProductionPlanController(productionPlanService, jwtManager)
	productionOrderService := service.NewProductionOrderService(productionOrderRepo, productRepo, ingredientRepo, inventoryRepo, conv)
	productionOrderController := controller.NewProductionOrderController(productionOrderService, jwtManager)
	finishedProductDispatchService := service.NewFinishedProductDispatchService(finishedProductDispatchRepo, finishedProductDispatchLineRepo, customerRepo, productRepo, inventoryRepo, userRepo, conv)
	finishedProductDispatchController := controller.NewFinishedProductDispatchController(finishedProductDispatchService, jwtManager)
	customerController := controller.NewCustomerController(customerService)
	productController := controller.NewProductController(productService)
	ingredientController := controller.NewIngredientController(ingredientService)
	orderController := controller.NewOrderController(orderService)
	orderSummaryController := controller.NewOrderSummaryController(orderSummaryService, jwtManager)
	roleService := service.NewRoleService(roleRepo, conv)
	roleController := controller.NewRoleController(roleService)
	userController := controller.NewUserController(userService, jwtManager)
	authGuard := middleware.AccessTokenGuard(jwtManager, blacklist)

	addr := os.Getenv("APP_ADDR")
	if addr == "" {
		addr = ":9999"
	}

	server := fuego.NewServer(
		fuego.WithAddr(addr),
		fuego.WithErrorSerializer(dto.ErrorSerializer),
		fuego.WithDisallowUnknownFields(true),
		fuego.WithCorsMiddleware(func(next http.Handler) http.Handler {
			return corsMiddleware(middleware.ContentLengthAll(next))
		}),
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

	RegisterRoutes(server, authController, customerController, productController, ingredientController, orderController, orderSummaryController, pinController, roleController, userController, companyController, departmentController, inventoryController, productionPlanController, productionOrderController, finishedProductDispatchController, func(next http.Handler) http.Handler {
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
