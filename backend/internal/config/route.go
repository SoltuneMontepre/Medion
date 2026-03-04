package config

import (
	"net/http"

	"backend/internal/controller"

	"github.com/go-fuego/fuego"
)

func RegisterRoutes(server *fuego.Server, authController *controller.AuthController, authGuardMiddleware func(next http.Handler) http.Handler) {
	authGroup := fuego.Group(server, "")

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
}
