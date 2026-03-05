package dto

import (
	"time"

	"github.com/google/uuid"
)

// CreateProductionOrderRequest for POST production-orders.
// Business rule: 1 order = 1 product (ProductID is the only product).
type CreateProductionOrderRequest struct {
	ProductID       uuid.UUID `json:"productId"`
	BatchNumber     string    `json:"batchNumber"`
	ProductionDate  string    `json:"productionDate"`  // YYYY-MM-DD
	ExpiryDate      string    `json:"expiryDate"`      // YYYY-MM-DD
	BatchSizeLit    float64   `json:"batchSizeLit"`
	QuantitySpec1   int       `json:"quantitySpec1"`  // e.g. 100ml bottles
	QuantitySpec2   int       `json:"quantitySpec2"`  // e.g. 500ml bottles
	PlanItemID      *uuid.UUID `json:"planItemId,omitempty"` // optional link to production plan item
}

// UpdateProductionOrderRequest for PUT production-orders/:id.
type UpdateProductionOrderRequest struct {
	BatchNumber    string  `json:"batchNumber"`
	ProductionDate string  `json:"productionDate"`
	ExpiryDate     string  `json:"expiryDate"`
	BatchSizeLit   float64 `json:"batchSizeLit"`
	QuantitySpec1  int     `json:"quantitySpec1"`
	QuantitySpec2  int     `json:"quantitySpec2"`
}

// ProductionOrderPayload for list/get.
type ProductionOrderPayload struct {
	ID              uuid.UUID `json:"id"`
	OrderNumber     string    `json:"orderNumber"`
	ProductID       uuid.UUID `json:"productId"`
	ProductCode     string    `json:"productCode"`
	ProductName     string    `json:"productName"`
	ProductForm     string    `json:"productForm"`
	Specification   string    `json:"specification"`
	BatchNumber     string    `json:"batchNumber"`
	ProductionDate  time.Time `json:"productionDate"`
	ExpiryDate      time.Time `json:"expiryDate"`
	BatchSizeLit    float64   `json:"batchSizeLit"`
	QuantitySpec1   int       `json:"quantitySpec1"`
	QuantitySpec2   int       `json:"quantitySpec2"`
	Status          string    `json:"status"`
	CreatedAt       time.Time `json:"createdAt"`
	CreatedBy       uuid.UUID `json:"createdBy"`
}

// ProductionOrderListResponse for paginated list.
type ProductionOrderListResponse struct {
	Items  []ProductionOrderPayload `json:"items"`
	Total  int64                     `json:"total"`
	Limit  int                       `json:"limit"`
	Offset int                       `json:"offset"`
}
