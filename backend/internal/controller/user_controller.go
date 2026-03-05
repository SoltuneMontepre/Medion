package controller

import (
	"context"
	"net/http"
	"strconv"

	"backend/internal/constant"
	"backend/internal/dto"
	"backend/internal/middleware"
	"backend/internal/security"
	"backend/internal/service"

	"github.com/go-fuego/fuego"
	"github.com/google/uuid"
)

type UserController struct {
	userService *service.UserService
	jwtManager  *security.JWTManager
}

func NewUserController(userService *service.UserService, jwtManager *security.JWTManager) *UserController {
	return &UserController{userService: userService, jwtManager: jwtManager}
}

func (uc *UserController) userIDFromContext(ctx context.Context) (uuid.UUID, error) {
	token, ok := middleware.GetAccessTokenFromContext(ctx)
	if !ok {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1011, Message: "access token is missing"}
	}
	claims, err := uc.jwtManager.ParseAccessToken(token)
	if err != nil {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1012, Message: "invalid or expired access token", Err: err}
	}
	id, err := uuid.Parse(claims.Subject)
	if err != nil {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1013, Message: "invalid user id in token", Err: err}
	}
	return id, nil
}

type listUsersResponse struct {
	Items []dto.UserPayload `json:"items"`
	Total int64             `json:"total"`
}

// List returns paginated users (for assign-role screen).
func (uc *UserController) List(c fuego.ContextNoBody) (*dto.Envelope[listUsersResponse], error) {
	page, _ := strconv.Atoi(c.QueryParam("page"))
	if page < 1 {
		page = 1
	}
	pageSize, _ := strconv.Atoi(c.QueryParam("pageSize"))
	if pageSize < 1 {
		pageSize = 20
	}
	items, total, err := uc.userService.List(c.Context(), page, pageSize)
	if err != nil {
		return nil, err
	}
	return dto.Ok(listUsersResponse{Items: items, Total: total}, "success", http.StatusOK), nil
}

// GetUserRoles returns roles assigned to the user.
func (uc *UserController) GetUserRoles(c fuego.ContextNoBody) (*dto.Envelope[[]dto.RolePayload], error) {
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2900, Message: constant.MsgUserNotFound}
	}
	roles, err := uc.userService.GetUserRoles(c.Context(), id)
	if err != nil {
		return nil, err
	}
	return dto.Ok(roles, "success", http.StatusOK), nil
}

// SetUserRoles replaces all roles for the user.
func (uc *UserController) SetUserRoles(c fuego.ContextWithBody[dto.SetUserRolesRequest]) (*dto.Envelope[any], error) {
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2900, Message: constant.MsgUserNotFound}
	}
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	currentUserID, err := uc.userIDFromContext(c.Context())
	if err != nil {
		return nil, err
	}
	if body.RoleIDs == nil {
		body.RoleIDs = []uuid.UUID{}
	}
	if err := uc.userService.SetUserRoles(c.Context(), id, body.RoleIDs, currentUserID); err != nil {
		return nil, err
	}
	return dto.Ok[any](nil, "success", http.StatusOK), nil
}

// SetSupervisor sets or clears the user's direct leader (supervisor). Body: { "supervisorId": "uuid" | null }.
func (uc *UserController) SetSupervisor(c fuego.ContextWithBody[dto.SetSupervisorRequest]) (*dto.Envelope[any], error) {
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2900, Message: constant.MsgUserNotFound}
	}
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	currentUserID, err := uc.userIDFromContext(c.Context())
	if err != nil {
		return nil, err
	}
	if err := uc.userService.SetSupervisor(c.Context(), id, body.SupervisorID, currentUserID); err != nil {
		return nil, err
	}
	return dto.Ok[any](nil, "success", http.StatusOK), nil
}

// SetDepartment sets or clears the user's department. Body: { "departmentId": "uuid" | null }.
func (uc *UserController) SetDepartment(c fuego.ContextWithBody[dto.SetDepartmentRequest]) (*dto.Envelope[any], error) {
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2900, Message: constant.MsgUserNotFound}
	}
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	currentUserID, err := uc.userIDFromContext(c.Context())
	if err != nil {
		return nil, err
	}
	if err := uc.userService.SetDepartment(c.Context(), id, body.DepartmentID, currentUserID); err != nil {
		return nil, err
	}
	return dto.Ok[any](nil, "success", http.StatusOK), nil
}
