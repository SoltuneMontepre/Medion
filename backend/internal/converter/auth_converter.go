package converter

import (
	"backend/internal/dto"
	"backend/internal/model"
)

// Converter handles conversions between models and DTOs
type Converter struct{}

// NewConverter creates a new Converter instance
func NewConverter() *Converter {
	return &Converter{}
}

// UserToUserPayload converts a User model to UserPayload DTO
func (c *Converter) UserToUserPayload(user model.User) dto.UserPayload {
	return dto.UserPayload{
		ID:       user.ID,
		Username: user.Username,
		Email:    user.Email,
	}
}

// UserToUserPayloadPtr converts a User model pointer to UserPayload DTO pointer
func (c *Converter) UserToUserPayloadPtr(user *model.User) *dto.UserPayload {
	if user == nil {
		return nil
	}
	return &dto.UserPayload{
		ID:       user.ID,
		Username: user.Username,
		Email:    user.Email,
	}
}

// UsersToUserPayloads converts a slice of User models to a slice of UserPayload DTOs
func (c *Converter) UsersToUserPayloads(users []model.User) []dto.UserPayload {
	payloads := make([]dto.UserPayload, len(users))
	for i, user := range users {
		payloads[i] = c.UserToUserPayload(user)
	}
	return payloads
}
