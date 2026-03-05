package dto

import (
	"time"

	"github.com/google/uuid"
)

// ProductionOrderIngredientInput for create/update.
type ProductionOrderIngredientInput struct {
	IngredientID       uuid.UUID `json:"ingredientId"`
	Quantity           float64   `json:"quantity"`           // Số lượng xuất
	QuantityAdjustment float64   `json:"quantityAdjustment"` // SL +/-
	Unit               string    `json:"unit"`                // kg, lít, ...
	Notes              string    `json:"notes"`
}

// CreateProductionOrderRequest for POST production-orders.
// Business rule: 1 order = 1 product (ProductID is the only product).
type CreateProductionOrderRequest struct {
	ProductID       uuid.UUID                      `json:"productId"`
	BatchNumber     string                         `json:"batchNumber"`
	ProductionDate  string                         `json:"productionDate"`  // YYYY-MM-DD
	ExpiryDate      string                         `json:"expiryDate"`     // YYYY-MM-DD
	BatchSizeLit    float64                        `json:"batchSizeLit"`
	QuantitySpec1   int                            `json:"quantitySpec1"`   // e.g. 100ml bottles
	QuantitySpec2   int                            `json:"quantitySpec2"`   // e.g. 500ml bottles
	PlanItemID      *uuid.UUID                     `json:"planItemId,omitempty"` // optional link to production plan item
	Ingredients     []ProductionOrderIngredientInput `json:"ingredients,omitempty"`
}

// UpdateProductionOrderRequest for PUT production-orders/:id.
type UpdateProductionOrderRequest struct {
	BatchNumber    string                           `json:"batchNumber"`
	ProductionDate string                           `json:"productionDate"`
	ExpiryDate     string                           `json:"expiryDate"`
	BatchSizeLit   float64                          `json:"batchSizeLit"`
	QuantitySpec1  int                              `json:"quantitySpec1"`
	QuantitySpec2  int                              `json:"quantitySpec2"`
	Ingredients    []ProductionOrderIngredientInput  `json:"ingredients,omitempty"`
}

// ProductionOrderIngredientPayload for list/get.
type ProductionOrderIngredientPayload struct {
	ID                 uuid.UUID `json:"id"`
	IngredientID      uuid.UUID `json:"ingredientId"`
	IngredientCode    string    `json:"ingredientCode"`
	IngredientName    string    `json:"ingredientName"`
	Quantity          float64   `json:"quantity"`
	QuantityAdjustment float64  `json:"quantityAdjustment"`
	Unit              string    `json:"unit"`
	Notes             string    `json:"notes"`
	Ordinal           int       `json:"ordinal"`
}

// ProductionOrderPayload for list/get.
type ProductionOrderPayload struct {
	ID              uuid.UUID                         `json:"id"`
	OrderNumber     string                            `json:"orderNumber"`
	ProductID       uuid.UUID                         `json:"productId"`
	ProductCode     string                            `json:"productCode"`
	ProductName     string                            `json:"productName"`
	ProductForm     string                            `json:"productForm"`
	Specification   string                            `json:"specification"`
	BatchNumber     string                            `json:"batchNumber"`
	ProductionDate  time.Time                         `json:"productionDate"`
	ExpiryDate      time.Time                         `json:"expiryDate"`
	BatchSizeLit    float64                           `json:"batchSizeLit"`
	QuantitySpec1   int                               `json:"quantitySpec1"`
	QuantitySpec2   int                               `json:"quantitySpec2"`
	Status          string                            `json:"status"`
	Ingredients     []ProductionOrderIngredientPayload `json:"ingredients,omitempty"`
	CreatedAt       time.Time                         `json:"createdAt"`
	CreatedBy       uuid.UUID                         `json:"createdBy"`
}

// ProductionOrderListResponse for paginated list.
type ProductionOrderListResponse struct {
	Items  []ProductionOrderPayload `json:"items"`
	Total  int64                     `json:"total"`
	Limit  int                       `json:"limit"`
	Offset int                       `json:"offset"`
}
