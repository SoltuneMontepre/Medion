package config

import (
	"net/http"

	"backend/internal/controller"

	"github.com/go-fuego/fuego"
)

func RegisterRoutes(server *fuego.Server, authController *controller.AuthController, customerController *controller.CustomerController, productController *controller.ProductController, orderController *controller.OrderController, orderSummaryController *controller.OrderSummaryController, pinController *controller.PINController, roleController *controller.RoleController, userController *controller.UserController, authGuardMiddleware func(next http.Handler) http.Handler) {
	authGroup := fuego.Group(server, "/api/v1")

	fuego.Post(authGroup, "/register", authController.Register,
		fuego.OptionSummary("Register user"),
		fuego.OptionTags("Authentication"),
	)

	fuego.Post(authGroup, "/login", authController.Login,
		fuego.OptionSummary("Login user"),
		fuego.OptionTags("Authentication"),
	)

	fuego.Post(authGroup, "/refresh", authController.Refresh,
		fuego.OptionSummary("Refresh access token"),
		fuego.OptionTags("Authentication"),
	)

	fuego.Post(authGroup, "/logout", authController.Logout,
		fuego.OptionSummary("Logout user"),
		fuego.OptionTags("Authentication"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	fuego.Get(authGroup, "/me", authController.Me,
		fuego.OptionSummary("Get current user"),
		fuego.OptionTags("Authentication"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	// Sale: customers, products, orders (protected by auth for GMP traceability)
	saleGroup := fuego.Group(authGroup, "/sale")
	fuego.Get(saleGroup, "/customers", customerController.List,
		fuego.OptionSummary("List customers"),
		fuego.OptionTags("Customers"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/customers/suggest", customerController.Suggest,
		fuego.OptionSummary("Suggest customers by code/name/phone"),
		fuego.OptionTags("Customers"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/customers/{id}", customerController.GetByID,
		fuego.OptionSummary("Get customer by ID"),
		fuego.OptionTags("Customers"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(saleGroup, "/customers", customerController.Create,
		fuego.OptionSummary("Create customer"),
		fuego.OptionTags("Customers"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(saleGroup, "/customers/{id}", customerController.Update,
		fuego.OptionSummary("Update customer"),
		fuego.OptionTags("Customers"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Delete(saleGroup, "/customers/{id}", customerController.Delete,
		fuego.OptionSummary("Delete customer"),
		fuego.OptionTags("Customers"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/products", productController.List,
		fuego.OptionSummary("List products"),
		fuego.OptionTags("Products"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/products/suggest", productController.Suggest,
		fuego.OptionSummary("Suggest products by code/name"),
		fuego.OptionTags("Products"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/products/{id}", productController.GetByID,
		fuego.OptionSummary("Get product by id"),
		fuego.OptionTags("Products"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(saleGroup, "/products", productController.Create,
		fuego.OptionSummary("Create product"),
		fuego.OptionTags("Products"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(saleGroup, "/products/{id}", productController.Update,
		fuego.OptionSummary("Update product"),
		fuego.OptionTags("Products"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Delete(saleGroup, "/products/{id}", productController.Delete,
		fuego.OptionSummary("Delete product"),
		fuego.OptionTags("Products"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/orders", orderController.List,
		fuego.OptionSummary("List orders"),
		fuego.OptionTags("Orders"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/orders/check-today", orderController.CheckCustomerOrderToday,
		fuego.OptionSummary("Check if customer has order today and get next order number"),
		fuego.OptionTags("Orders"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(saleGroup, "/orders", orderController.Create,
		fuego.OptionSummary("Create and sign order"),
		fuego.OptionTags("Orders"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/orders/{id}", orderController.GetByID,
		fuego.OptionSummary("Get order by id"),
		fuego.OptionTags("Orders"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	// Order summary (Bảng tổng hợp đơn hàng) — read-only; each sale admin sees only their own (OwnerID)
	fuego.Get(saleGroup, "/order-summaries", orderSummaryController.List,
		fuego.OptionSummary("List order summaries for current sale admin"),
		fuego.OptionTags("Order Summaries"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/order-summaries/by-date", orderSummaryController.GetByDate,
		fuego.OptionSummary("Get order summary by date (e.g. today) for current sale admin"),
		fuego.OptionTags("Order Summaries"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/order-summaries/{id}", orderSummaryController.GetByID,
		fuego.OptionSummary("Get order summary by id"),
		fuego.OptionTags("Order Summaries"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	// PIN management (digital signing credential)
	pinGroup := fuego.Group(authGroup, "/pin")
	fuego.Get(pinGroup, "", pinController.Status,
		fuego.OptionSummary("Get PIN status"),
		fuego.OptionTags("PIN"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(pinGroup, "", pinController.Set,
		fuego.OptionSummary("Set PIN (first time)"),
		fuego.OptionTags("PIN"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(pinGroup, "", pinController.Change,
		fuego.OptionSummary("Change PIN"),
		fuego.OptionTags("PIN"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(pinGroup, "/verify", pinController.Verify,
		fuego.OptionSummary("Verify PIN"),
		fuego.OptionTags("PIN"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	// Roles: CRUD and hierarchy (parent role)
	roleGroup := fuego.Group(authGroup, "/roles")
	fuego.Get(roleGroup, "", roleController.List,
		fuego.OptionSummary("List roles (paginated)"),
		fuego.OptionTags("Roles"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(roleGroup, "/all", roleController.ListAll,
		fuego.OptionSummary("List all roles for hierarchy"),
		fuego.OptionTags("Roles"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(roleGroup, "/{id}", roleController.GetByID,
		fuego.OptionSummary("Get role by id"),
		fuego.OptionTags("Roles"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(roleGroup, "", roleController.Create,
		fuego.OptionSummary("Create role"),
		fuego.OptionTags("Roles"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(roleGroup, "/{id}", roleController.Update,
		fuego.OptionSummary("Update role"),
		fuego.OptionTags("Roles"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Delete(roleGroup, "/{id}", roleController.Delete,
		fuego.OptionSummary("Delete role"),
		fuego.OptionTags("Roles"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	// Users: list and assign roles (admin / HR)
	userGroup := fuego.Group(authGroup, "/users")
	fuego.Get(userGroup, "", userController.List,
		fuego.OptionSummary("List users (paginated)"),
		fuego.OptionTags("Users"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(userGroup, "/{id}/roles", userController.GetUserRoles,
		fuego.OptionSummary("Get roles assigned to user"),
		fuego.OptionTags("Users"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(userGroup, "/{id}/roles", userController.SetUserRoles,
		fuego.OptionSummary("Set user roles (replace all)"),
		fuego.OptionTags("Users"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(userGroup, "/{id}/supervisor", userController.SetSupervisor,
		fuego.OptionSummary("Set user's direct leader (supervisor); pass null to clear"),
		fuego.OptionTags("Users"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
}
