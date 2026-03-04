package controller

import (
	"net/http"
	"strconv"

	"backend/internal/constant"
	"backend/internal/dto"
	"backend/internal/service"

	"github.com/go-fuego/fuego"
	"github.com/google/uuid"
)

type RoleController struct {
	roleService *service.RoleService
}

func NewRoleController(roleService *service.RoleService) *RoleController {
	return &RoleController{roleService: roleService}
}

type listRolesResponse struct {
	Items []dto.RolePayload `json:"items"`
	Total int64             `json:"total"`
}

// List returns paginated roles.
func (rc *RoleController) List(c fuego.ContextNoBody) (*dto.Envelope[listRolesResponse], error) {
	page, _ := strconv.Atoi(c.QueryParam("page"))
	if page < 1 {
		page = 1
	}
	pageSize, _ := strconv.Atoi(c.QueryParam("pageSize"))
	if pageSize < 1 {
		pageSize = 20
	}
	items, total, err := rc.roleService.List(c.Context(), page, pageSize)
	if err != nil {
		return nil, err
	}
	return dto.Ok(listRolesResponse{Items: items, Total: total}, "success", http.StatusOK), nil
}

// ListAll returns all roles (for hierarchy editor).
func (rc *RoleController) ListAll(c fuego.ContextNoBody) (*dto.Envelope[[]dto.RolePayload], error) {
	items, err := rc.roleService.ListAll(c.Context())
	if err != nil {
		return nil, err
	}
	return dto.Ok(items, "success", http.StatusOK), nil
}

// GetByID returns one role by id.
func (rc *RoleController) GetByID(c fuego.ContextNoBody) (*dto.Envelope[dto.RolePayload], error) {
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2699, Message: constant.MsgRoleNotFound}
	}
	payload, err := rc.roleService.GetByID(c.Context(), id)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}

// Create creates a new role.
func (rc *RoleController) Create(c fuego.ContextWithBody[dto.CreateRoleRequest]) (*dto.Envelope[dto.RolePayload], error) {
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	payload, err := rc.roleService.Create(c.Context(), body)
	if err != nil {
		return nil, err
	}
	c.SetStatus(http.StatusCreated)
	return dto.Ok(*payload, "success", http.StatusCreated), nil
}

// Update updates a role.
func (rc *RoleController) Update(c fuego.ContextWithBody[dto.UpdateRoleRequest]) (*dto.Envelope[dto.RolePayload], error) {
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2699, Message: constant.MsgRoleNotFound}
	}
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	payload, err := rc.roleService.Update(c.Context(), id, body)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}

// Delete deletes a role.
func (rc *RoleController) Delete(c fuego.ContextNoBody) (*dto.Envelope[any], error) {
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2699, Message: constant.MsgRoleNotFound}
	}
	if err := rc.roleService.Delete(c.Context(), id); err != nil {
		return nil, err
	}
	return dto.Ok[any](nil, "success", http.StatusOK), nil
}
