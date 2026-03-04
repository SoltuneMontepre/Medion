package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Order status
const (
	OrderStatusDraft  = "draft"
	OrderStatusSigned = "signed"
)

type Order struct {
	Base        `gorm:"embedded"`
	CustomerID  uuid.UUID  `gorm:"type:uuid;not null;index:idx_order_customer"`
	OrderNumber string     `gorm:"size:32;not null;uniqueIndex:idx_order_number"`
	OrderDate   time.Time  `gorm:"not null;index:idx_order_date"` // date part used for "today" check
	Status      string     `gorm:"size:20;not null;default:draft"`
	Customer    *Customer  `gorm:"foreignKey:CustomerID"`
}

func (Order) TableName() string {
	return "orders"
}

func (o *Order) BeforeCreate(tx *gorm.DB) error {
	if o.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		o.ID = id
	}
	if o.Status == "" {
		o.Status = OrderStatusDraft
	}
	return nil
}
