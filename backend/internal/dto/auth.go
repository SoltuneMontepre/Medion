package dto

import "github.com/google/uuid"

type RegisterRequest struct {
	Username string `json:"username" validate:"required,min=3,max=64"`
	Email    string `json:"email" validate:"required,email,max=255"`
	Password string `json:"password" validate:"required,min=8,max=128"`
}

type LoginRequest struct {
	Email    string `json:"email" validate:"required,email,max=255"`
	Password string `json:"password" validate:"required,min=8,max=128"`
}

type UserPayload struct {
	ID       uuid.UUID `json:"id"`
	Username string    `json:"username"`
	Email    string    `json:"email"`
}

type AuthData struct {
	AccessToken string      `json:"accessToken"`
	User        UserPayload `json:"user"`
}

type LogoutData struct {
	LoggedOut bool `json:"loggedOut"`
}
