package dto

import (
	"encoding/json"
	"net/http"
)

type Envelope[T any] struct {
	Status  string `json:"status"`
	Data    T      `json:"data"`
	Message string `json:"message"`
	Code    int    `json:"code"`
}

type ErrorEnvelope struct {
	Status  string `json:"status"`
	Data    any    `json:"data"`
	Message string `json:"message"`
	Code    int    `json:"code"`
}

func Ok[T any](data T, message string, code int) *Envelope[T] {
	return &Envelope[T]{
		Status:  "success",
		Data:    data,
		Message: message,
		Code:    code,
	}
}

func NewErrorEnvelope(message string, code int) ErrorEnvelope {
	return ErrorEnvelope{
		Status:  "error",
		Data:    nil,
		Message: message,
		Code:    code,
	}
}

type statusCoder interface {
	StatusCode() int
}

func ErrorSerializer(w http.ResponseWriter, _ *http.Request, err error) {
	statusCode := http.StatusInternalServerError
	if sc, ok := err.(statusCoder); ok {
		statusCode = sc.StatusCode()
	}

	message := http.StatusText(statusCode)
	code := statusCode
	if appErr, ok := err.(*AppError); ok {
		message = appErr.Message
		code = appErr.Code
		statusCode = appErr.StatusCode()
	} else if err != nil {
		message = err.Error()
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	_ = json.NewEncoder(w).Encode(NewErrorEnvelope(message, code))
}
