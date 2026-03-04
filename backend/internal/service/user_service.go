package service

import (
	"context"
	"errors"
	"net/http"

	"backend/internal/constant"
	"backend/internal/converter"
	"backend/internal/dto"
	"backend/internal/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type UserService struct {
	users     *repository.UserRepository
	roles     *repository.RoleRepository
	converter *converter.Converter
}

func NewUserService(users *repository.UserRepository, roles *repository.RoleRepository, conv *converter.Converter) *UserService {
	return &UserService{users: users, roles: roles, converter: conv}
}

// List returns paginated users (id, username, email).
func (s *UserService) List(ctx context.Context, page, pageSize int) ([]dto.UserPayload, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	offset := (page - 1) * pageSize
	list, err := s.users.FindAll(ctx, pageSize, offset)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2901, Message: constant.MsgUserNotFound, Err: err}
	}
	total, err := s.users.Count(ctx)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2902, Message: constant.MsgUserNotFound, Err: err}
	}
	return s.converter.UsersToUserPayloads(list), total, nil
}

// GetUserRoles returns roles assigned to the user.
func (s *UserService) GetUserRoles(ctx context.Context, userID uuid.UUID) ([]dto.RolePayload, error) {
	if _, err := s.users.FindByID(ctx, userID); err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2903, Message: constant.MsgUserNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2904, Message: constant.MsgUserNotFound, Err: err}
	}
	roleIDs, err := s.users.GetRoleIDsForUser(ctx, userID)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2905, Message: "failed to load user roles", Err: err}
	}
	if len(roleIDs) == 0 {
		return []dto.RolePayload{}, nil
	}
	var result []dto.RolePayload
	for _, roleID := range roleIDs {
		role, err := s.roles.FindByID(ctx, roleID)
		if err != nil {
			continue
		}
		result = append(result, s.converter.RoleToPayload(*role))
	}
	return result, nil
}

// SetUserRoles replaces all role assignments for the user. Validates user and all role IDs exist.
func (s *UserService) SetUserRoles(ctx context.Context, userID uuid.UUID, roleIDs []uuid.UUID, currentUserID uuid.UUID) error {
	if _, err := s.users.FindByID(ctx, userID); err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2903, Message: constant.MsgUserNotFound}
		}
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2904, Message: constant.MsgUserNotFound, Err: err}
	}
	for _, roleID := range roleIDs {
		if _, err := s.roles.FindByID(ctx, roleID); err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2803, Message: constant.MsgRoleNotFound}
			}
			return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2804, Message: constant.MsgRoleNotFound, Err: err}
		}
	}
	if err := s.users.SetUserRoles(ctx, userID, roleIDs, currentUserID); err != nil {
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2906, Message: "failed to set user roles", Err: err}
	}
	return nil
}

// SetSupervisor sets or clears the user's direct leader. Validates: user exists, supervisor exists when set,
// no self-assignment, no circular reporting chain.
func (s *UserService) SetSupervisor(ctx context.Context, userID uuid.UUID, supervisorID *uuid.UUID, currentUserID uuid.UUID) error {
	user, err := s.users.FindByID(ctx, userID)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2903, Message: constant.MsgUserNotFound}
		}
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2904, Message: constant.MsgUserNotFound, Err: err}
	}
	if supervisorID != nil {
		if *supervisorID == userID {
			return &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2907, Message: constant.MsgSupervisorSelf}
		}
		if _, err := s.users.FindByID(ctx, *supervisorID); err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2908, Message: constant.MsgSupervisorNotFound}
			}
			return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2909, Message: constant.MsgSupervisorNotFound, Err: err}
		}
		chain, err := s.users.GetSupervisorChain(ctx, *supervisorID)
		if err != nil {
			return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2910, Message: constant.MsgSupervisorNotFound, Err: err}
		}
		for _, id := range chain {
			if id == userID {
				return &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2911, Message: constant.MsgSupervisorCycle}
			}
		}
	}
	user.SupervisorID = supervisorID
	user.UpdatedBy = currentUserID
	if err := s.users.Update(ctx, user); err != nil {
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2912, Message: "failed to set supervisor", Err: err}
	}
	return nil
}
