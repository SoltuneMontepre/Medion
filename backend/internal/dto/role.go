package dto

import (
	"github.com/google/uuid"
)

// RolePayload for list/get responses.
type RolePayload struct {
	ID           uuid.UUID  `json:"id"`
	Code         string     `json:"code"`
	Name         string     `json:"name"`
	Description  string     `json:"description"`
	ParentRoleID *uuid.UUID `json:"parentRoleId,omitempty"`
	ParentCode   string     `json:"parentCode,omitempty"` // for display
}

// CreateRoleRequest for POST /roles.
type CreateRoleRequest struct {
	Code         string     `json:"code"`
	Name         string     `json:"name"`
	Description  string     `json:"description"`
	ParentRoleID *uuid.UUID `json:"parentRoleId,omitempty"`
}

// UpdateRoleRequest for PUT /roles/:id.
type UpdateRoleRequest struct {
	Code         string     `json:"code"`
	Name         string     `json:"name"`
	Description  string     `json:"description"`
	ParentRoleID *uuid.UUID `json:"parentRoleId,omitempty"`
}
