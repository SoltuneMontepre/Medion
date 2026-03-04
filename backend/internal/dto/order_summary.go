package dto

import (
	"github.com/google/uuid"
	"time"
)

// OrderSummaryItemPayload for create/update request.
type OrderSummaryItemPayload struct {
	ProductID uuid.UUID `json:"productId"`
	Quantity  int       `json:"quantity"`
}

// OrderSummaryItemDetail for detail response (includes product info).
type OrderSummaryItemDetail struct {
	ProductID       uuid.UUID `json:"productId"`
	ProductCode     string    `json:"productCode"`
	ProductName     string    `json:"productName"`
	PackageSize     string    `json:"packageSize"`
	PackageUnit     string    `json:"packageUnit"`
	ProductType     string    `json:"productType"`
	PackagingType   string    `json:"packagingType"`
	Quantity        int       `json:"quantity"`
}

// CreateOrderSummaryRequest for POST order-summaries.
type CreateOrderSummaryRequest struct {
	SummaryDate string                    `json:"summaryDate"` // YYYY-MM-DD (ngày tổng hợp đơn)
	Items       []OrderSummaryItemPayload `json:"items"`
}

// UpdateOrderSummaryRequest for PUT order-summaries/:id.
type UpdateOrderSummaryRequest struct {
	SummaryDate string                    `json:"summaryDate"` // YYYY-MM-DD; must remain unique per day
	Items       []OrderSummaryItemPayload `json:"items"`
}

// OrderSummaryPayload for list.
type OrderSummaryPayload struct {
	ID          uuid.UUID   `json:"id"`
	OwnerID     uuid.UUID   `json:"ownerId"` // sale admin who owns this summary
	SummaryDate time.Time   `json:"summaryDate"`
	CreatedAt   time.Time   `json:"createdAt"`
	CreatedBy   uuid.UUID   `json:"createdBy"`
	ApprovedBy  *uuid.UUID  `json:"approvedBy,omitempty"`
	ItemCount   int         `json:"itemCount"`
}

// OrderSummaryDetailPayload for get by id (with items).
type OrderSummaryDetailPayload struct {
	OrderSummaryPayload
	Items []OrderSummaryItemDetail `json:"items"`
}
