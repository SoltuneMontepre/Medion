package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// FinishedProductDispatchLine is one product line: MÃ SP, QUY, DẠNG, SỐ, SỐ LÔ, NSX, HSD.
type FinishedProductDispatchLine struct {
	Base               `gorm:"embedded"`
	DispatchID         uuid.UUID  `gorm:"type:uuid;not null;index:idx_dispatch_line_dispatch"`
	ProductID          uuid.UUID  `gorm:"type:uuid;not null;index:idx_dispatch_line_product"`
	Ordinal            int        `gorm:"not null"`
	Quantity           int        `gorm:"not null"`
	LotNumber          string     `gorm:"size:64"`
	ManufacturingDate  *time.Time `gorm:"type:date"`
	ExpiryDate         *time.Time `gorm:"type:date"`

	Product *Product `gorm:"foreignKey:ProductID"`
}

func (FinishedProductDispatchLine) TableName() string {
	return "finished_product_dispatch_lines"
}

func (l *FinishedProductDispatchLine) BeforeCreate(tx *gorm.DB) error {
	if l.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		l.ID = id
	}
	return nil
}
