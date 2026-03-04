package dto

import "github.com/google/uuid"

// SetUserRolesRequest for PUT /users/:id/roles — replace user's roles with the given list.
type SetUserRolesRequest struct {
	RoleIDs []uuid.UUID `json:"roleIds"`
}
