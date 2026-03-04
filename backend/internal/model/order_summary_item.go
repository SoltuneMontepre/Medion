package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// OrderSummaryItem links OrderSummary to Product with aggregated quantity (many-to-many with Product).
type OrderSummaryItem struct {
	Base          `gorm:"embedded"`
	OrderSummaryID uuid.UUID `gorm:"type:uuid;not null;index:idx_order_summary_item_summary"`
	ProductID     uuid.UUID `gorm:"type:uuid;not null;index:idx_order_summary_item_product"`
	Quantity      int       `gorm:"not null"` // aggregated quantity
	Product       *Product  `gorm:"foreignKey:ProductID"`
}

func (OrderSummaryItem) TableName() string {
	return "order_summary_items"
}

func (osi *OrderSummaryItem) BeforeCreate(tx *gorm.DB) error {
	if osi.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		osi.ID = id
	}
	return nil
}
