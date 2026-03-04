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

// UserToUserPayload converts a User model to UserPayload DTO (includes SupervisorID; Supervisor when preloaded).
func (c *Converter) UserToUserPayload(user model.User) dto.UserPayload {
	p := dto.UserPayload{
		ID:           user.ID,
		Username:     user.Username,
		Email:        user.Email,
		SupervisorID: user.SupervisorID,
	}
	if user.Supervisor != nil {
		sup := c.UserToUserPayload(*user.Supervisor)
		sup.Supervisor = nil
		sup.SupervisorID = nil
		p.Supervisor = &sup
	}
	return p
}

// UserToUserPayloadPtr converts a User model pointer to UserPayload DTO pointer
func (c *Converter) UserToUserPayloadPtr(user *model.User) *dto.UserPayload {
	if user == nil {
		return nil
	}
	p := c.UserToUserPayload(*user)
	return &p
}

// UsersToUserPayloads converts a slice of User models to a slice of UserPayload DTOs
func (c *Converter) UsersToUserPayloads(users []model.User) []dto.UserPayload {
	payloads := make([]dto.UserPayload, len(users))
	for i, user := range users {
		payloads[i] = c.UserToUserPayload(user)
	}
	return payloads
}
