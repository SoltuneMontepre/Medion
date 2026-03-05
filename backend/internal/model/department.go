package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Department belongs to a Company. Users can be assigned to a department.
type Department struct {
	Base      `gorm:"embedded"`
	CompanyID uuid.UUID `gorm:"type:uuid;not null;uniqueIndex:idx_department_company_code"`
	Code      string   `gorm:"size:64;not null;uniqueIndex:idx_department_company_code"`
	Name      string   `gorm:"size:255;not null"`
	Description string `gorm:"size:512"`

	Company *Company `gorm:"foreignKey:CompanyID"`
	Users   []User   `gorm:"foreignKey:DepartmentID"`
}

func (Department) TableName() string {
	return "departments"
}

func (d *Department) BeforeCreate(tx *gorm.DB) error {
	if d.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		d.ID = id
	}
	return nil
}
