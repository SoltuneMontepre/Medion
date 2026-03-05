package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Company represents the organization (single-tenant: one company; departments belong to it).
type Company struct {
	Base   `gorm:"embedded"`
	Code   string `gorm:"size:32;not null;uniqueIndex:idx_company_code"`
	Name   string `gorm:"size:255;not null"`
	Active bool   `gorm:"not null;default:true"`

	Departments []Department `gorm:"foreignKey:CompanyID"`
}

func (Company) TableName() string {
	return "companies"
}

func (c *Company) BeforeCreate(tx *gorm.DB) error {
	if c.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		c.ID = id
	}
	return nil
}
