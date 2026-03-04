package service

import (
	"context"
	"errors"
	"net/http"
	"regexp"

	"backend/internal/constant"
	"backend/internal/dto"
	"backend/internal/repository"
	"backend/internal/security"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

var pinRegexp = regexp.MustCompile(`^\d{4}$`)

type PINService struct {
	users *repository.UserRepository
	jwt   *security.JWTManager
}

func NewPINService(users *repository.UserRepository, jwt *security.JWTManager) *PINService {
	return &PINService{users: users, jwt: jwt}
}

func (s *PINService) userIDFromToken(accessToken string) (uuid.UUID, error) {
	claims, err := s.jwt.ParseAccessToken(accessToken)
	if err != nil {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1600, Message: "invalid or expired access token", Err: err}
	}
	id, err := uuid.Parse(claims.Subject)
	if err != nil {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1601, Message: "invalid user id in token", Err: err}
	}
	return id, nil
}

func validatePIN(pin string) error {
	if pin == "" {
		return &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 1602, Message: constant.MsgPINRequired}
	}
	if !pinRegexp.MatchString(pin) {
		return &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 1603, Message: constant.MsgPINInvalid}
	}
	return nil
}

// Status returns whether the authenticated user has a PIN set.
func (s *PINService) Status(ctx context.Context, accessToken string) (dto.PINStatusPayload, error) {
	id, err := s.userIDFromToken(accessToken)
	if err != nil {
		return dto.PINStatusPayload{}, err
	}
	user, err := s.users.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.PINStatusPayload{}, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 1604, Message: "user not found"}
		}
		return dto.PINStatusPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1605, Message: "failed to load user", Err: err}
	}
	return dto.PINStatusPayload{HasPIN: user.PIN != nil && *user.PIN != ""}, nil
}

// SetPIN sets a PIN for the first time. Returns error if PIN is already set.
func (s *PINService) SetPIN(ctx context.Context, accessToken, pin string) error {
	if err := validatePIN(pin); err != nil {
		return err
	}
	id, err := s.userIDFromToken(accessToken)
	if err != nil {
		return err
	}
	user, err := s.users.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 1606, Message: "user not found"}
		}
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1607, Message: "failed to load user", Err: err}
	}
	if user.PIN != nil && *user.PIN != "" {
		return &dto.AppError{HTTPStatus: http.StatusConflict, Code: 1608, Message: constant.MsgPINAlreadySet}
	}
	hashed, err := security.HashPassword(pin)
	if err != nil {
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1609, Message: "failed to hash PIN", Err: err}
	}
	user.PIN = &hashed
	if err := s.users.Update(ctx, user); err != nil {
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1610, Message: "failed to save PIN", Err: err}
	}
	return nil
}

// ChangePIN replaces an existing PIN after verifying the old one.
func (s *PINService) ChangePIN(ctx context.Context, accessToken, oldPIN, newPIN string) error {
	if err := validatePIN(oldPIN); err != nil {
		return err
	}
	if err := validatePIN(newPIN); err != nil {
		return err
	}
	id, err := s.userIDFromToken(accessToken)
	if err != nil {
		return err
	}
	user, err := s.users.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 1611, Message: "user not found"}
		}
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1612, Message: "failed to load user", Err: err}
	}
	if user.PIN == nil || *user.PIN == "" {
		return &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 1613, Message: constant.MsgPINNotSet}
	}
	ok, err := security.VerifyPassword(oldPIN, *user.PIN)
	if err != nil {
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1614, Message: "failed to verify PIN", Err: err}
	}
	if !ok {
		return &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1615, Message: constant.MsgPINIncorrect}
	}
	hashed, err := security.HashPassword(newPIN)
	if err != nil {
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1616, Message: "failed to hash PIN", Err: err}
	}
	user.PIN = &hashed
	if err := s.users.Update(ctx, user); err != nil {
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1617, Message: "failed to save PIN", Err: err}
	}
	return nil
}

// Verify checks a PIN for the given user ID. Used internally by other services (e.g. order signing).
func (s *PINService) Verify(ctx context.Context, userID uuid.UUID, pin string) (bool, error) {
	if err := validatePIN(pin); err != nil {
		return false, err
	}
	user, err := s.users.FindByID(ctx, userID)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return false, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 1618, Message: "user not found"}
		}
		return false, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1619, Message: "failed to load user", Err: err}
	}
	if user.PIN == nil || *user.PIN == "" {
		return false, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 1620, Message: constant.MsgPINNotSet}
	}
	ok, err := security.VerifyPassword(pin, *user.PIN)
	if err != nil {
		return false, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1621, Message: "failed to verify PIN", Err: err}
	}
	return ok, nil
}

// UserIDFromToken returns the user ID from the access token. Used by order service for CreatedBy and list scoping.
func (s *PINService) UserIDFromToken(accessToken string) (uuid.UUID, error) {
	return s.userIDFromToken(accessToken)
}

// VerifyByToken checks a PIN using the access token to identify the user.
// Exposed as an API endpoint and used by the order signing flow.
func (s *PINService) VerifyByToken(ctx context.Context, accessToken, pin string) (dto.VerifyPINPayload, error) {
	id, err := s.userIDFromToken(accessToken)
	if err != nil {
		return dto.VerifyPINPayload{}, err
	}
	valid, err := s.Verify(ctx, id, pin)
	if err != nil {
		return dto.VerifyPINPayload{}, err
	}
	return dto.VerifyPINPayload{Valid: valid}, nil
}
