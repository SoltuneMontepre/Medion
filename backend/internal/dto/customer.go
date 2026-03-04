package dto

import "github.com/google/uuid"

// CreateCustomerRequest is the body for POST /customers.
type CreateCustomerRequest struct {
	Name    string `json:"name"`
	Address string `json:"address"`
	Phone   string `json:"phone"`
}

// CustomerPayload is returned in list and create responses.
type CustomerPayload struct {
	ID            uuid.UUID `json:"id"`
	Code          string    `json:"code"`
	Name          string    `json:"name"`
	Address       string    `json:"address"`
	Phone         string    `json:"phone"`
	ContactPerson string    `json:"contactPerson"`
}
