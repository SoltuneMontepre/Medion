package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// OrderSummary (Bảng tổng hợp đơn hàng): daily aggregation of orders by product.
// Read-only in app: shown by sale admin for their scope. Each sale admin has their own page (OwnerID).
// One summary per day per owner (unique SummaryDate + OwnerID). Data populated by batch job or external process.
type OrderSummary struct {
	Base        `gorm:"embedded"`
	OwnerID     uuid.UUID  `gorm:"type:uuid;not null;uniqueIndex:idx_order_summary_date_owner"` // sale admin who owns this summary
	SummaryDate time.Time  `gorm:"type:date;not null;uniqueIndex:idx_order_summary_date_owner"`
	ApprovedBy  *uuid.UUID `gorm:"type:uuid"`
	Items       []OrderSummaryItem `gorm:"foreignKey:OrderSummaryID"`
}

func (OrderSummary) TableName() string {
	return "order_summaries"
}

func (os *OrderSummary) BeforeCreate(tx *gorm.DB) error {
	if os.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		os.ID = id
	}
	return nil
}
