package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// WarehouseType: raw (NVP), semi (BTP), finished (TP).
const (
	WarehouseTypeRaw     = "raw"
	WarehouseTypeSemi    = "semi"
	WarehouseTypeFinished = "finished"
)

// Inventory is current stock (tồn kho) per product per warehouse type. GMP traceability via Base.
type Inventory struct {
	Base          `gorm:"embedded"`
	ProductID     uuid.UUID `gorm:"type:uuid;not null;uniqueIndex:idx_inventory_product_warehouse"`
	WarehouseType string    `gorm:"size:32;not null;uniqueIndex:idx_inventory_product_warehouse"` // raw | semi | finished
	Quantity      int64     `gorm:"not null;default:0"`                                            // Số lượng tồn

	Product *Product `gorm:"foreignKey:ProductID"`
}

func (Inventory) TableName() string {
	return "inventories"
}

func (i *Inventory) BeforeCreate(tx *gorm.DB) error {
	if i.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		i.ID = id
	}
	return nil
}
