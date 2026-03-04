package config

import (
	"net/http"

	"backend/internal/controller"

	"github.com/go-fuego/fuego"
)

func RegisterRoutes(server *fuego.Server, authController *controller.AuthController, customerController *controller.CustomerController, productController *controller.ProductController, orderController *controller.OrderController, authGuardMiddleware func(next http.Handler) http.Handler) {
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
	fuego.Post(saleGroup, "/customers", customerController.Create,
		fuego.OptionSummary("Create customer"),
		fuego.OptionTags("Customers"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/products/suggest", productController.Suggest,
		fuego.OptionSummary("Suggest products by code/name"),
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
}
