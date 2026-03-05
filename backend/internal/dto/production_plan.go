package dto

import (
	"time"

	"github.com/google/uuid"
)

// ProductionPlanItemPayload for request (create/update).
type ProductionPlanItemPayload struct {
	ProductID       uuid.UUID `json:"productId"`
	Ordinal         int       `json:"ordinal"`
	PlannedQuantity int       `json:"plannedQuantity"`
}

// CreateProductionPlanRequest for POST production-plans.
type CreateProductionPlanRequest struct {
	PlanDate string                     `json:"planDate"` // YYYY-MM-DD
	Items    []ProductionPlanItemPayload `json:"items"`
}

// UpdateProductionPlanRequest for PUT production-plans/:id.
type UpdateProductionPlanRequest struct {
	PlanDate string                     `json:"planDate"`
	Items    []ProductionPlanItemPayload `json:"items"`
}

// RejectProductionPlanRequest for POST production-plans/:id/reject.
type RejectProductionPlanRequest struct {
	Reason string `json:"reason"`
}

// ProductionPlanItemDetail for response (includes product display info: MÃ SP, TÊN, QUY, DẠNG, ĐÓNG GÓI).
type ProductionPlanItemDetail struct {
	ID              uuid.UUID `json:"id"`
	ProductID       uuid.UUID `json:"productId"`
	ProductCode     string    `json:"productCode"`
	ProductName     string    `json:"productName"`
	Specification   string    `json:"specification"`   // PackageSize + PackageUnit (e.g. 100gr)
	ProductForm     string    `json:"productForm"`     // ProductType: Bột uống, Dung dịch, ...
	PackagingForm   string    `json:"packagingForm"`   // PackagingType: Gói, Chai, ...
	Ordinal         int       `json:"ordinal"`
	PlannedQuantity int       `json:"plannedQuantity"`
}

// ProductionPlanPayload for list/get.
type ProductionPlanPayload struct {
	ID         uuid.UUID                  `json:"id"`
	PlanDate   time.Time                  `json:"planDate"`
	Status     string                     `json:"status"`
	CreatedAt  time.Time                  `json:"createdAt"`
	CreatedBy  uuid.UUID                  `json:"createdBy"`
	ApprovedAt *time.Time                  `json:"approvedAt,omitempty"`
	ApprovedBy *uuid.UUID                 `json:"approvedBy,omitempty"`
	Items      []ProductionPlanItemDetail `json:"items"`
}
