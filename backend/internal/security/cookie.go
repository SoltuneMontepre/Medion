package security

import (
	"net/http"
	"time"
)

const RefreshCookieName = "refresh_token"

func BuildRefreshCookie(token string, maxAgeSec int) http.Cookie {
	return http.Cookie{
		Name:     RefreshCookieName,
		Value:    token,
		Path:     "/refresh",
		MaxAge:   maxAgeSec,
		HttpOnly: true,
		Secure:   true,
		SameSite: http.SameSiteLaxMode,
	}
}

func ExpireRefreshCookie() http.Cookie {
	return http.Cookie{
		Name:     RefreshCookieName,
		Value:    "",
		Path:     "/refresh",
		Expires:  time.Unix(0, 0),
		MaxAge:   -1,
		HttpOnly: true,
		Secure:   true,
		SameSite: http.SameSiteLaxMode,
	}
}
