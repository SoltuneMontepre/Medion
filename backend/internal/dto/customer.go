package dto

import "github.com/google/uuid"

// CreateCustomerRequest is the body for POST /customers.
// Code and Name are provided by Sales (NV phòng KD) when creating a new customer.
type CreateCustomerRequest struct {
	Code          string `json:"code"`
	Name          string `json:"name"`
	Address       string `json:"address"`
	Phone         string `json:"phone"`
	ContactPerson string `json:"contactPerson"`
}

// UpdateCustomerRequest is the body for PUT /customers/:id.
type UpdateCustomerRequest struct {
	Name          string `json:"name"`
	Address       string `json:"address"`
	Phone         string `json:"phone"`
	ContactPerson string `json:"contactPerson"`
}

// CustomerPayload is returned in list, create, update, get responses.
type CustomerPayload struct {
	ID            uuid.UUID `json:"id"`
	Code          string    `json:"code"`
	Name          string    `json:"name"`
	Address       string    `json:"address"`
	Phone         string    `json:"phone"`
	ContactPerson string    `json:"contactPerson"`
}
