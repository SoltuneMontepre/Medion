package middleware

import (
	"bytes"
	"net/http"
	"strconv"
)

// ContentLengthAuth buffers the response for auth endpoints (login, register, refresh)
// and sends it with an explicit Content-Length. Kept for backwards compatibility;
// prefer ContentLengthAll for global use.
func ContentLengthAuth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			next.ServeHTTP(w, r)
			return
		}
		path := r.URL.Path
		if path != "/api/v1/login" && path != "/api/v1/register" && path != "/api/v1/refresh" {
			next.ServeHTTP(w, r)
			return
		}
		bw := &bufferWriter{ResponseWriter: w, body: &bytes.Buffer{}}
		next.ServeHTTP(bw, r)
		bw.flush()
	})
}

// ContentLengthAll buffers every response and sends it with an explicit Content-Length.
// This avoids chunked transfer encoding that can cause "Failed to parse HTTP, 83 does not match 13"
// on Dart HttpClient (Windows). Apply globally so all API responses work from Flutter desktop.
func ContentLengthAll(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		bw := &bufferWriter{ResponseWriter: w, body: &bytes.Buffer{}}
		next.ServeHTTP(bw, r)
		bw.flush()
	})
}

type bufferWriter struct {
	http.ResponseWriter
	body       *bytes.Buffer
	statusCode int
	written    bool
}

func (b *bufferWriter) WriteHeader(code int) {
	b.statusCode = code
	b.written = true
}

func (b *bufferWriter) Write(p []byte) (int, error) {
	return b.body.Write(p)
}

func (b *bufferWriter) flush() {
	if !b.written {
		b.statusCode = http.StatusOK
	}
	b.ResponseWriter.Header().Set("Content-Length", strconv.Itoa(b.body.Len()))
	b.ResponseWriter.WriteHeader(b.statusCode)
	_, _ = b.body.WriteTo(b.ResponseWriter)
}
