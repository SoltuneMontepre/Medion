package security

import (
	"errors"
	"fmt"
	"os"
	"time"

	"backend/internal/model"

	"github.com/golang-jwt/jwt/v5"
)

const (
	TokenTypeAccess  = "access"
	TokenTypeRefresh = "refresh"
)

type TokenClaims struct {
	UserID   string `json:"uid"`
	Email    string `json:"email"`
	Username string `json:"username"`
	TokenTyp string `json:"typ"`
	jwt.RegisteredClaims
}

type JWTManager struct {
	secret     []byte
	issuer     string
	accessTTL  time.Duration
	refreshTTL time.Duration
}

func NewJWTManagerFromEnv() (*JWTManager, error) {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		return nil, errors.New("JWT_SECRET is required")
	}

	issuer := os.Getenv("JWT_ISSUER")
	if issuer == "" {
		issuer = "medion-backend"
	}

	accessTTL := 15 * time.Minute
	refreshTTL := 7 * 24 * time.Hour

	return &JWTManager{
		secret:     []byte(secret),
		issuer:     issuer,
		accessTTL:  accessTTL,
		refreshTTL: refreshTTL,
	}, nil
}

func (j *JWTManager) AccessTTL() time.Duration {
	return j.accessTTL
}

func (j *JWTManager) RefreshTTL() time.Duration {
	return j.refreshTTL
}

func (j *JWTManager) GenerateTokenPair(user model.User) (string, string, error) {
	now := time.Now()
	accessClaims := TokenClaims{
		UserID:   user.ID.String(),
		Email:    user.Email,
		Username: user.Username,
		TokenTyp: TokenTypeAccess,
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    j.issuer,
			Subject:   user.ID.String(),
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(j.accessTTL)),
		},
	}

	refreshClaims := TokenClaims{
		UserID:   user.ID.String(),
		Email:    user.Email,
		Username: user.Username,
		TokenTyp: TokenTypeRefresh,
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    j.issuer,
			Subject:   user.ID.String(),
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(j.refreshTTL)),
		},
	}

	accessToken, err := j.sign(accessClaims)
	if err != nil {
		return "", "", err
	}

	refreshToken, err := j.sign(refreshClaims)
	if err != nil {
		return "", "", err
	}

	return accessToken, refreshToken, nil
}

func (j *JWTManager) GenerateAccessFromRefresh(refreshClaims TokenClaims) (string, error) {
	now := time.Now()
	accessClaims := TokenClaims{
		UserID:   refreshClaims.UserID,
		Email:    refreshClaims.Email,
		Username: refreshClaims.Username,
		TokenTyp: TokenTypeAccess,
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    j.issuer,
			Subject:   refreshClaims.Subject,
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(j.accessTTL)),
		},
	}
	return j.sign(accessClaims)
}

func (j *JWTManager) ParseAccessToken(token string) (TokenClaims, error) {
	claims, err := j.parse(token)
	if err != nil {
		return TokenClaims{}, err
	}
	if claims.TokenTyp != TokenTypeAccess {
		return TokenClaims{}, errors.New("invalid token type")
	}
	return claims, nil
}

func (j *JWTManager) ParseRefreshToken(token string) (TokenClaims, error) {
	claims, err := j.parse(token)
	if err != nil {
		return TokenClaims{}, err
	}
	if claims.TokenTyp != TokenTypeRefresh {
		return TokenClaims{}, errors.New("invalid token type")
	}
	return claims, nil
}

func (j *JWTManager) TTLUntilExpiry(token string) time.Duration {
	claims, err := j.parse(token)
	if err != nil {
		return 0
	}
	if claims.ExpiresAt == nil {
		return 0
	}
	ttl := time.Until(claims.ExpiresAt.Time)
	if ttl < 0 {
		return 0
	}
	return ttl
}

func (j *JWTManager) sign(claims TokenClaims) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString(j.secret)
	if err != nil {
		return "", fmt.Errorf("sign token: %w", err)
	}
	return signed, nil
}

func (j *JWTManager) parse(token string) (TokenClaims, error) {
	claims := TokenClaims{}
	parsed, err := jwt.ParseWithClaims(token, &claims, func(_ *jwt.Token) (any, error) {
		return j.secret, nil
	})
	if err != nil {
		return TokenClaims{}, err
	}
	if !parsed.Valid {
		return TokenClaims{}, errors.New("invalid token")
	}
	return claims, nil
}
