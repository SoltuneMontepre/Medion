package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// ProductionOrderIngredient is one ingredient line (nguyên liệu) on a production order.
// Ingredient is from the ingredients master table. Quantity = Số lượng xuất; QuantityAdjustment = SL +/-.
type ProductionOrderIngredient struct {
	Base `gorm:"embedded"`

	ProductionOrderID  uuid.UUID `gorm:"type:uuid;not null;index:idx_po_ingredient_order"`
	IngredientID      uuid.UUID `gorm:"type:uuid;not null;index:idx_po_ingredient_ingredient"`
	Quantity          float64   `gorm:"not null"`   // Số lượng xuất (kg, lít, ...)
	QuantityAdjustment float64  `gorm:"default:0"` // SL +/- (điều chỉnh)
	Unit              string    `gorm:"size:32;not null;default:kg"`
	Notes             string    `gorm:"size:255"`
	Ordinal           int       `gorm:"not null;default:0"` // Thứ tự hiển thị

	ProductionOrder *ProductionOrder `gorm:"foreignKey:ProductionOrderID"`
	Ingredient      *Ingredient      `gorm:"foreignKey:IngredientID"`
}

func (ProductionOrderIngredient) TableName() string {
	return "production_order_ingredients"
}

func (i *ProductionOrderIngredient) BeforeCreate(tx *gorm.DB) error {
	if i.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		i.ID = id
	}
	return nil
}
