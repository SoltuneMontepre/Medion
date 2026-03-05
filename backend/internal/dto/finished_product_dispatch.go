package dto

import (
	"time"

	"github.com/google/uuid"
)

// FinishedProductDispatchLinePayload for request (create/update).
type FinishedProductDispatchLinePayload struct {
	ProductID         uuid.UUID `json:"productId"`
	Ordinal           int      `json:"ordinal"`
	Quantity          int      `json:"quantity"`
	LotNumber         string   `json:"lotNumber,omitempty"`
	ManufacturingDate string   `json:"manufacturingDate,omitempty"` // YYYY-MM-DD
	ExpiryDate        string   `json:"expiryDate,omitempty"`       // YYYY-MM-DD
}

// CreateFinishedProductDispatchRequest for POST.
type CreateFinishedProductDispatchRequest struct {
	CustomerID  uuid.UUID                         `json:"customerId"`
	OrderNumber string                            `json:"orderNumber"`
	Address     string                            `json:"address"`
	Phone       string                            `json:"phone"`
	Items       []FinishedProductDispatchLinePayload `json:"items"`
}

// UpdateFinishedProductDispatchRequest for PUT.
type UpdateFinishedProductDispatchRequest struct {
	OrderNumber string                            `json:"orderNumber"`
	Address     string                            `json:"address"`
	Phone       string                            `json:"phone"`
	Items       []FinishedProductDispatchLinePayload `json:"items"`
}

// RejectFinishedProductDispatchRequest for POST .../reject (yêu cầu sửa).
type RejectFinishedProductDispatchRequest struct {
	Reason string `json:"reason"`
}

// FinishedProductDispatchLineDetail for response (with product display).
type FinishedProductDispatchLineDetail struct {
	ID                uuid.UUID  `json:"id"`
	ProductID         uuid.UUID  `json:"productId"`
	ProductCode       string     `json:"productCode"`
	ProductName       string     `json:"productName"`
	Specification     string     `json:"specification"`
	ProductForm       string     `json:"productForm"`
	PackagingForm     string     `json:"packagingForm"`
	Ordinal           int        `json:"ordinal"`
	Quantity          int        `json:"quantity"`
	LotNumber         string     `json:"lotNumber,omitempty"`
	ManufacturingDate *time.Time `json:"manufacturingDate,omitempty"`
	ExpiryDate        *time.Time `json:"expiryDate,omitempty"`
}

// FinishedProductDispatchPayload for list/get.
type FinishedProductDispatchPayload struct {
	ID               uuid.UUID                           `json:"id"`
	CustomerID       uuid.UUID                           `json:"customerId"`
	CustomerCode     string                              `json:"customerCode"`
	CustomerName     string                              `json:"customerName"`
	OrderNumber      string                              `json:"orderNumber"`
	Address          string                              `json:"address"`
	Phone            string                              `json:"phone"`
	Status           string                              `json:"status"`
	RejectionReason  string                              `json:"rejectionReason,omitempty"`
	CreatedAt       time.Time                            `json:"createdAt"`
	CreatedBy       uuid.UUID                            `json:"createdBy"`
	ApprovedAt      *time.Time                           `json:"approvedAt,omitempty"`
	ApprovedBy      *uuid.UUID                           `json:"approvedBy,omitempty"`
	Items           []FinishedProductDispatchLineDetail `json:"items"`
}

// FinishedProductDispatchListResponse for paginated list.
type FinishedProductDispatchListResponse struct {
	Items  []FinishedProductDispatchPayload `json:"items"`
	Total  int64                            `json:"total"`
	Limit  int                              `json:"limit"`
	Offset int                              `json:"offset"`
}
