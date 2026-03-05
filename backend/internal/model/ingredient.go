package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Ingredient is raw material master data (nguyên liệu). Used in production orders.
type Ingredient struct {
	Base `gorm:"embedded"`

	Code        string `gorm:"size:64;not null;uniqueIndex:idx_ingredient_code"` // Mã NL
	Name        string `gorm:"size:255;not null"`
	Unit        string `gorm:"size:32;not null;default:kg"` // Đơn vị tính: kg, lít, ...
	Description string `gorm:"size:512"`
}

func (Ingredient) TableName() string {
	return "ingredients"
}

func (i *Ingredient) BeforeCreate(tx *gorm.DB) error {
	if i.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		i.ID = id
	}
	return nil
}
