package middleware

import (
	"context"
	"encoding/json"
	"net/http"
	"strings"

	"backend/internal/dto"
	"backend/internal/security"

	cache "github.com/patrickmn/go-cache"
)

func AccessTokenGuard(jwtManager *security.JWTManager, blacklist *cache.Cache) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			authHeader := r.Header.Get("Authorization")
			if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
				writeUnauthorized(w, "missing or invalid Authorization header")
				return
			}

			token := strings.TrimPrefix(authHeader, "Bearer ")
			if _, found := blacklist.Get(token); found {
				writeUnauthorized(w, "access token has been revoked")
				return
			}

			if _, err := jwtManager.ParseAccessToken(token); err != nil {
				writeUnauthorized(w, "invalid or expired access token")
				return
			}

			ctx := context.WithValue(r.Context(), dto.ContextKeyAccessToken, token)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func GetAccessTokenFromContext(ctx context.Context) (string, bool) {
	token, ok := ctx.Value(dto.ContextKeyAccessToken).(string)
	return token, ok
}

func writeUnauthorized(w http.ResponseWriter, message string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusUnauthorized)
	_ = json.NewEncoder(w).Encode(dto.NewErrorEnvelope(message, http.StatusUnauthorized))
}
