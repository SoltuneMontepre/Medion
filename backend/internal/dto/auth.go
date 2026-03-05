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
	ID             uuid.UUID   `json:"id"`
	Username       string      `json:"username"`
	Email          string      `json:"email"`
	SupervisorID   *uuid.UUID  `json:"supervisorId,omitempty"`
	Supervisor     *UserPayload `json:"supervisor,omitempty"`   // minimal leader info when loaded
	DepartmentID   *uuid.UUID  `json:"departmentId,omitempty"`
	DepartmentName string     `json:"departmentName,omitempty"` // when department is preloaded
}

type AuthData struct {
	AccessToken string      `json:"accessToken"`
	User        UserPayload `json:"user"`
}

type LogoutData struct {
	LoggedOut bool `json:"loggedOut"`
}

type SetPINRequest struct {
	PIN string `json:"pin"`
}

type ChangePINRequest struct {
	OldPIN string `json:"oldPin"`
	NewPIN string `json:"newPin"`
}

type VerifyPINRequest struct {
	PIN string `json:"pin"`
}

type PINStatusPayload struct {
	HasPIN bool `json:"hasPin"`
}

type VerifyPINPayload struct {
	Valid bool `json:"valid"`
}
