package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// ProductionPlanItem is one line in the production plan: product + planned quantity (SỐ).
type ProductionPlanItem struct {
	Base             `gorm:"embedded"`
	ProductionPlanID uuid.UUID `gorm:"type:uuid;not null;index:idx_plan_item_plan"`
	ProductID        uuid.UUID `gorm:"type:uuid;not null;index:idx_plan_item_product"`
	Ordinal          int       `gorm:"not null"` // STT
	PlannedQuantity  int       `gorm:"not null"` // Số

	Product *Product `gorm:"foreignKey:ProductID"`
}

func (ProductionPlanItem) TableName() string {
	return "production_plan_items"
}

func (i *ProductionPlanItem) BeforeCreate(tx *gorm.DB) error {
	if i.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		i.ID = id
	}
	return nil
}
