package dto

import "github.com/google/uuid"

// CreateDepartmentRequest is the body for POST /departments.
type CreateDepartmentRequest struct {
	CompanyID   string `json:"companyId"`
	Code        string `json:"code"`
	Name        string `json:"name"`
	Description string `json:"description"`
}

// UpdateDepartmentRequest is the body for PUT /departments/:id.
type UpdateDepartmentRequest struct {
	Code        string `json:"code"`
	Name        string `json:"name"`
	Description string `json:"description"`
}

// DepartmentPayload is returned in list, create, update, get responses.
type DepartmentPayload struct {
	ID          uuid.UUID  `json:"id"`
	CompanyID   uuid.UUID  `json:"companyId"`
	CompanyName string     `json:"companyName,omitempty"`
	Code        string     `json:"code"`
	Name        string     `json:"name"`
	Description string     `json:"description"`
}

// CompanyPayload is returned when listing companies or as reference (e.g. in department suggest).
type CompanyPayload struct {
	ID     uuid.UUID `json:"id"`
	Code   string    `json:"code"`
	Name   string    `json:"name"`
	Active bool      `json:"active"`
}
