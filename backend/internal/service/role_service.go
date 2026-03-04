package service

import (
	"context"
	"errors"
	"net/http"
	"strings"

	"backend/internal/constant"
	"backend/internal/converter"
	"backend/internal/dto"
	"backend/internal/model"
	"backend/internal/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type RoleService struct {
	roles     *repository.RoleRepository
	converter *converter.Converter
}

func NewRoleService(roles *repository.RoleRepository, conv *converter.Converter) *RoleService {
	return &RoleService{roles: roles, converter: conv}
}

// List returns paginated roles with parent info.
func (s *RoleService) List(ctx context.Context, page, pageSize int) ([]dto.RolePayload, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	offset := (page - 1) * pageSize
	list, err := s.roles.FindAll(ctx, pageSize, offset)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2801, Message: constant.MsgRoleNotFound, Err: err}
	}
	total, err := s.roles.Count(ctx)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2802, Message: constant.MsgRoleNotFound, Err: err}
	}
	return s.converter.RolesToPayloads(list), total, nil
}

// ListAll returns all roles (no paging) for hierarchy display.
func (s *RoleService) ListAll(ctx context.Context) ([]dto.RolePayload, error) {
	list, err := s.roles.FindAllNoPaging(ctx)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2801, Message: constant.MsgRoleNotFound, Err: err}
	}
	return s.converter.RolesToPayloads(list), nil
}

// GetByID returns one role by id.
func (s *RoleService) GetByID(ctx context.Context, id uuid.UUID) (*dto.RolePayload, error) {
	role, err := s.roles.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2803, Message: constant.MsgRoleNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2804, Message: constant.MsgRoleNotFound, Err: err}
	}
	// Preload parent if needed
	if role.ParentRoleID != nil {
		parent, _ := s.roles.FindByID(ctx, *role.ParentRoleID)
		if parent != nil {
			role.ParentRole = parent
		}
	}
	payload := s.converter.RoleToPayload(*role)
	return &payload, nil
}

// isDescendant checks if roleID is in the ancestor chain of targetID (would create cycle if targetID became parent of roleID).
func (s *RoleService) isDescendant(ctx context.Context, roleID, targetID uuid.UUID) (bool, error) {
	if roleID == targetID {
		return true, nil
	}
	role, err := s.roles.FindByID(ctx, roleID)
	if err != nil || role == nil || role.ParentRoleID == nil {
		return false, nil
	}
	return s.isDescendant(ctx, *role.ParentRoleID, targetID)
}

// Create creates a new role. Validates code uniqueness and prevents circular parent.
func (s *RoleService) Create(ctx context.Context, req dto.CreateRoleRequest) (*dto.RolePayload, error) {
	code := strings.TrimSpace(req.Code)
	name := strings.TrimSpace(req.Name)
	if code == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2810, Message: constant.MsgRoleCodeAlreadyExists}
	}
	if name == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2811, Message: constant.MsgRoleNameAlreadyExists}
	}
	exists, err := s.roles.ExistsByCode(ctx, code)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2812, Message: constant.MsgRoleNotFound, Err: err}
	}
	if exists {
		return nil, &dto.AppError{HTTPStatus: http.StatusConflict, Code: 2813, Message: constant.MsgRoleCodeAlreadyExists}
	}
	if req.ParentRoleID != nil && *req.ParentRoleID != uuid.Nil {
		parent, err := s.roles.FindByID(ctx, *req.ParentRoleID)
		if err != nil || parent == nil {
			return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2814, Message: constant.MsgInvalidRoleID}
		}
		// no cycle: new role has no children yet
	}
	role := model.Role{
		Code:         code,
		Name:         name,
		Description:  strings.TrimSpace(req.Description),
		ParentRoleID: req.ParentRoleID,
	}
	if err := s.roles.Create(ctx, &role); err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2815, Message: constant.MsgRoleNotFound, Err: err}
	}
	payload := s.converter.RoleToPayload(role)
	return &payload, nil
}

// Update updates a role. Validates code uniqueness and prevents circular parent.
func (s *RoleService) Update(ctx context.Context, id uuid.UUID, req dto.UpdateRoleRequest) (*dto.RolePayload, error) {
	role, err := s.roles.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2803, Message: constant.MsgRoleNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2804, Message: constant.MsgRoleNotFound, Err: err}
	}
	code := strings.TrimSpace(req.Code)
	name := strings.TrimSpace(req.Name)
	if code == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2810, Message: constant.MsgRoleCodeAlreadyExists}
	}
	if name == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2811, Message: constant.MsgRoleNameAlreadyExists}
	}
	exists, err := s.roles.ExistsByCodeExcludingID(ctx, code, id)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2812, Message: constant.MsgRoleNotFound, Err: err}
	}
	if exists {
		return nil, &dto.AppError{HTTPStatus: http.StatusConflict, Code: 2813, Message: constant.MsgRoleCodeAlreadyExists}
	}
	if req.ParentRoleID != nil && *req.ParentRoleID != uuid.Nil {
		if *req.ParentRoleID == id {
			return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2816, Message: constant.MsgInvalidRoleID}
		}
		parent, err := s.roles.FindByID(ctx, *req.ParentRoleID)
		if err != nil || parent == nil {
			return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2814, Message: constant.MsgInvalidRoleID}
		}
		// Prevent cycle: parent must not be a descendant of id
		desc, err := s.isDescendant(ctx, *req.ParentRoleID, id)
		if err != nil {
			return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2817, Message: constant.MsgRoleNotFound, Err: err}
		}
		if desc {
			return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2816, Message: constant.MsgInvalidRoleID}
		}
	}
	role.Code = code
	role.Name = name
	role.Description = strings.TrimSpace(req.Description)
	role.ParentRoleID = req.ParentRoleID
	if err := s.roles.Update(ctx, role); err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2815, Message: constant.MsgRoleNotFound, Err: err}
	}
	payload := s.converter.RoleToPayload(*role)
	if role.ParentRoleID != nil {
		parent, _ := s.roles.FindByID(ctx, *role.ParentRoleID)
		if parent != nil {
			payload.ParentCode = parent.Code
		}
	}
	return &payload, nil
}

// Delete deletes a role. Fails if any user has this role or if any role has this as parent.
func (s *RoleService) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := s.roles.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2803, Message: constant.MsgRoleNotFound}
		}
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2804, Message: constant.MsgRoleNotFound, Err: err}
	}
	hasUsers, err := s.roles.HasUserAssignments(ctx, id)
	if err != nil {
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2818, Message: constant.MsgRoleNotFound, Err: err}
	}
	if hasUsers {
		return &dto.AppError{HTTPStatus: http.StatusConflict, Code: 2819, Message: constant.MsgRoleNotFound}
	}
	childCount, err := s.roles.CountChildren(ctx, id)
	if err != nil {
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2820, Message: constant.MsgRoleNotFound, Err: err}
	}
	if childCount > 0 {
		return &dto.AppError{HTTPStatus: http.StatusConflict, Code: 2821, Message: constant.MsgRoleNotFound}
	}
	return s.roles.Delete(ctx, id)
}
