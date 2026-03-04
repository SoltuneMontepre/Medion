package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type OrderItem struct {
	Base      `gorm:"embedded"`
	OrderID   uuid.UUID `gorm:"type:uuid;not null;index:idx_order_item_order"`
	ProductID uuid.UUID `gorm:"type:uuid;not null;index:idx_order_item_product"`
	Quantity  int       `gorm:"not null"` // integer > 0
	Product   *Product  `gorm:"foreignKey:ProductID"`
}

func (OrderItem) TableName() string {
	return "order_items"
}

func (oi *OrderItem) BeforeCreate(tx *gorm.DB) error {
	if oi.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		oi.ID = id
	}
	return nil
}
