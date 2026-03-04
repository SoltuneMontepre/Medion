package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Product: identifier is user-facing "mã sản phẩm" (manual input, no UUID in display).
// Quy Cách = package_size + package_unit (e.g. 100, "gr" -> 100gr).
type Product struct {
	Base          `gorm:"embedded"`
	Code          string `gorm:"size:64;not null;uniqueIndex:idx_product_code"` // Mã SP (manual)
	Name          string `gorm:"size:255;not null"`
	PackageSize   string `gorm:"size:32;not null"`  // e.g. "100", "500"
	PackageUnit   string `gorm:"size:32;not null"` // e.g. "gr", "ml"
	ProductType   string `gorm:"size:128;not null"` // Dạng SP: Bột uống, Dung dịch tiêm, ...
	PackagingType string `gorm:"size:64;not null"`  // Dạng đóng gói: Gói, Chai, ...
}

func (Product) TableName() string {
	return "products"
}

func (p *Product) BeforeCreate(tx *gorm.DB) error {
	if p.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		p.ID = id
	}
	return nil
}
