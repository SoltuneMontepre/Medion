package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Production order status.
const (
	ProductionOrderStatusDraft   = "draft"
	ProductionOrderStatusActive  = "active"
	ProductionOrderStatusDone    = "done"
	ProductionOrderStatusCanceled = "canceled"
)

// ProductionOrder is a manufacturing order (Lệnh sản xuất).
// Business rule: 1 production order = 1 product only.
// Created from approved production plan items; each plan item becomes one order.
type ProductionOrder struct {
	Base `gorm:"embedded"`

	OrderNumber   string    `gorm:"size:64;not null;uniqueIndex:idx_production_order_number"` // LSX15102025
	ProductID     uuid.UUID `gorm:"type:uuid;not null;index:idx_production_order_product"`
	BatchNumber   string    `gorm:"size:64;not null;index:idx_production_order_batch"`
	ProductionDate time.Time `gorm:"type:date;not null"`
	ExpiryDate    time.Time `gorm:"type:date;not null"`
	BatchSizeLit  float64   `gorm:"not null"` // Cỡ lô (liters)
	QuantitySpec1 int       `gorm:"not null"` // Số lượng QC1 (e.g. 100ml bottles)
	QuantitySpec2 int       `gorm:"not null"` // Số lượng QC2 (e.g. 500ml bottles)
	Status        string    `gorm:"size:20;not null;default:draft"`

	ProductionPlanItemID *uuid.UUID `gorm:"type:uuid;index:idx_production_order_plan_item"` // optional link to plan item

	Product *Product `gorm:"foreignKey:ProductID"`
}

func (ProductionOrder) TableName() string {
	return "production_orders"
}

func (o *ProductionOrder) BeforeCreate(tx *gorm.DB) error {
	if o.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		o.ID = id
	}
	if o.Status == "" {
		o.Status = ProductionOrderStatusDraft
	}
	return nil
}
