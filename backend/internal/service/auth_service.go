package service

import (
	"context"
	"errors"
	"net/http"
	"strings"
	"time"

	"backend/internal/constant"
	"backend/internal/converter"
	"backend/internal/dto"
	"backend/internal/model"
	"backend/internal/repository"
	"backend/internal/security"

	cache "github.com/patrickmn/go-cache"
	"gorm.io/gorm"
)

type AuthService struct {
	users     *repository.UserRepository
	jwt       *security.JWTManager
	blacklist *cache.Cache
	converter *converter.Converter
}

func NewAuthService(users *repository.UserRepository, jwt *security.JWTManager, blacklist *cache.Cache, converter *converter.Converter) *AuthService {
	return &AuthService{users: users, jwt: jwt, blacklist: blacklist, converter: converter}
}

func (s *AuthService) Register(ctx context.Context, req dto.RegisterRequest) (dto.AuthData, string, error) {
	email := strings.TrimSpace(strings.ToLower(req.Email))
	username := strings.TrimSpace(req.Username)
	password := strings.TrimSpace(req.Password)
	if email == "" || username == "" || password == "" {
		return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 1001, Message: constant.MsgAuthFieldsRequired}
	}

	exists, err := s.users.ExistsByEmail(ctx, email)
	if err != nil {
		return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1500, Message: "failed to check email", Err: err}
	}
	if exists {
		return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusConflict, Code: 1002, Message: constant.MsgEmailAlreadyExists}
	}

	exists, err = s.users.ExistsByUsername(ctx, username)
	if err != nil {
		return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1501, Message: "failed to check username", Err: err}
	}
	if exists {
		return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusConflict, Code: 1003, Message: constant.MsgUsernameAlreadyExists}
	}

	hashed, err := security.HashPassword(password)
	if err != nil {
		return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1502, Message: "failed to hash password", Err: err}
	}

	newUser := model.User{
		Username: username,
		Email:    email,
		Password: hashed,
	}
	if err := s.users.Create(ctx, &newUser); err != nil {
		return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1503, Message: "failed to create user", Err: err}
	}

	accessToken, refreshToken, err := s.jwt.GenerateTokenPair(newUser)
	if err != nil {
		return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1504, Message: "failed to generate tokens", Err: err}
	}

	return dto.AuthData{
		AccessToken: accessToken,
		User:        s.converter.UserToUserPayload(newUser),
	}, refreshToken, nil
}

func (s *AuthService) Login(ctx context.Context, req dto.LoginRequest) (dto.AuthData, string, error) {
	email := strings.TrimSpace(strings.ToLower(req.Email))
	if email == "" || strings.TrimSpace(req.Password) == "" {
		return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 1004, Message: "email and password are required"}
	}

	user, err := s.users.FindByEmail(ctx, email)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1005, Message: constant.MsgInvalidLoginCredentials}
		}
		return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1505, Message: "failed to query user", Err: err}
	}

	ok, err := security.VerifyPassword(req.Password, user.Password)
	if err != nil {
		return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1506, Message: "failed to verify password", Err: err}
	}
	if !ok {
		return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1006, Message: constant.MsgInvalidLoginCredentials}
	}

	accessToken, refreshToken, err := s.jwt.GenerateTokenPair(*user)
	if err != nil {
		return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1507, Message: "failed to generate tokens", Err: err}
	}

	return dto.AuthData{
		AccessToken: accessToken,
		User:        s.converter.UserToUserPayload(*user),
	}, refreshToken, nil
}

func (s *AuthService) Refresh(ctx context.Context, refreshToken string) (dto.AuthData, string, error) {
	claims, err := s.jwt.ParseRefreshToken(refreshToken)
	if err != nil {
		return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1007, Message: "invalid or expired refresh token", Err: err}
	}

	user, err := s.users.FindByID(ctx, claims.Subject)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1008, Message: "user not found"}
		}
		return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1508, Message: "failed to query user", Err: err}
	}

	accessToken, nextRefreshToken, err := s.jwt.GenerateTokenPair(*user)
	if err != nil {
		return dto.AuthData{}, "", &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1509, Message: "failed to generate tokens", Err: err}
	}

	return dto.AuthData{
		AccessToken: accessToken,
		User:        s.converter.UserToUserPayload(*user),
	}, nextRefreshToken, nil
}

func (s *AuthService) Logout(accessToken string) error {
	if strings.TrimSpace(accessToken) == "" {
		return &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1009, Message: "missing access token"}
	}

	ttl := s.jwt.TTLUntilExpiry(accessToken)
	if ttl <= 0 {
		ttl = time.Minute
	}
	s.blacklist.Set(accessToken, true, ttl)
	return nil
}

func (s *AuthService) RefreshCookieMaxAge() int {
	return int(s.jwt.RefreshTTL().Seconds())
}

func (s *AuthService) Me(ctx context.Context, accessToken string) (dto.UserPayload, error) {
	claims, err := s.jwt.ParseAccessToken(accessToken)
	if err != nil {
		return dto.UserPayload{}, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1012, Message: "invalid or expired access token", Err: err}
	}

	user, err := s.users.FindByIDWithAssociations(ctx, claims.Subject)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.UserPayload{}, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 1013, Message: "user not found"}
		}
		return dto.UserPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1510, Message: "failed to load user", Err: err}
	}

	return s.converter.UserToUserPayload(*user), nil
}
