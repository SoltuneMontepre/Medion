package model

import (
	"encoding/binary"
	"fmt"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Customer holds customer info for sales/orders. Code is auto-generated (e.g. cus-123-456).
type Customer struct {
	Base    `gorm:"embedded"`
	Code    string `gorm:"size:32;not null;uniqueIndex:idx_customer_code"`
	Name    string `gorm:"size:255;not null"`
	Address string `gorm:"size:512;not null"`
	Phone   string `gorm:"size:20;not null;uniqueIndex:idx_customer_phone"`
}

func (Customer) TableName() string {
	return "customers"
}

func (c *Customer) BeforeCreate(tx *gorm.DB) error {
	if c.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		c.ID = id
	}
	if c.Code == "" {
		n := binary.BigEndian.Uint32(c.ID[:4]) % 1000000
		c.Code = fmt.Sprintf("cus-%03d-%03d", n/1000, n%1000)
	}
	return nil
}
