package dto

import "github.com/google/uuid"

// SetUserRolesRequest for PUT /users/:id/roles — replace user's roles with the given list.
type SetUserRolesRequest struct {
	RoleIDs []uuid.UUID `json:"roleIds"`
}

// SetSupervisorRequest for PUT /users/:id/supervisor — set or clear the user's direct leader.
// SupervisorID nil = clear supervisor (user has no direct leader).
type SetSupervisorRequest struct {
	SupervisorID *uuid.UUID `json:"supervisorId"`
}
