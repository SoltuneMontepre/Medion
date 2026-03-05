package controller

import (
	"net/http"

	"backend/internal/dto"
	"backend/internal/middleware"
	"backend/internal/security"
	"backend/internal/service"

	"github.com/go-fuego/fuego"
)

type AuthController struct {
	authService  *service.AuthService
	userService  *service.UserService
}

func NewAuthController(authService *service.AuthService, userService *service.UserService) *AuthController {
	return &AuthController{authService: authService, userService: userService}
}

func (a *AuthController) Register(c fuego.ContextWithBody[dto.RegisterRequest]) (*dto.Envelope[dto.AuthData], error) {
	body, err := c.Body()
	if err != nil {
		return nil, err
	}

	data, refreshToken, err := a.authService.Register(c.Context(), body)
	if err != nil {
		return nil, err
	}

	c.SetCookie(security.BuildRefreshCookie(refreshToken, a.authService.RefreshCookieMaxAge()))
	c.SetStatus(http.StatusCreated)
	return dto.Ok(data, "register success", http.StatusCreated), nil
}

func (a *AuthController) Login(c fuego.ContextWithBody[dto.LoginRequest]) (*dto.Envelope[dto.AuthData], error) {
	body, err := c.Body()
	if err != nil {
		return nil, err
	}

	data, refreshToken, err := a.authService.Login(c.Context(), body)
	if err != nil {
		return nil, err
	}

	c.SetCookie(security.BuildRefreshCookie(refreshToken, a.authService.RefreshCookieMaxAge()))
	return dto.Ok(data, "login success", http.StatusOK), nil
}

func (a *AuthController) Refresh(c fuego.ContextNoBody) (*dto.Envelope[dto.AuthData], error) {
	cookie, err := c.Cookie(security.RefreshCookieName)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1010, Message: "refresh token cookie is missing", Err: err}
	}

	data, refreshToken, err := a.authService.Refresh(c.Context(), cookie.Value)
	if err != nil {
		return nil, err
	}

	c.SetCookie(security.BuildRefreshCookie(refreshToken, a.authService.RefreshCookieMaxAge()))
	return dto.Ok(data, "refresh success", http.StatusOK), nil
}

func (a *AuthController) Logout(c fuego.ContextNoBody) (*dto.Envelope[dto.LogoutData], error) {
	accessToken, ok := middleware.GetAccessTokenFromContext(c.Context())
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1011, Message: "access token is missing"}
	}

	if err := a.authService.Logout(accessToken); err != nil {
		return nil, err
	}

	c.SetCookie(security.ExpireRefreshCookie())
	return dto.Ok(dto.LogoutData{LoggedOut: true}, "logout success", http.StatusOK), nil
}

func (a *AuthController) Me(c fuego.ContextNoBody) (*dto.Envelope[dto.UserPayload], error) {
	accessToken, ok := middleware.GetAccessTokenFromContext(c.Context())
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1011, Message: "access token is missing"}
	}

	user, err := a.authService.Me(c.Context(), accessToken)
	if err != nil {
		return nil, err
	}

	return dto.Ok(user, "success", http.StatusOK), nil
}

// GetMyRoles returns roles assigned to the current authenticated user.
func (a *AuthController) GetMyRoles(c fuego.ContextNoBody) (*dto.Envelope[[]dto.RolePayload], error) {
	accessToken, ok := middleware.GetAccessTokenFromContext(c.Context())
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1011, Message: "access token is missing"}
	}
	user, err := a.authService.Me(c.Context(), accessToken)
	if err != nil {
		return nil, err
	}
	roles, err := a.userService.GetUserRoles(c.Context(), user.ID)
	if err != nil {
		return nil, err
	}
	return dto.Ok(roles, "success", http.StatusOK), nil
}
