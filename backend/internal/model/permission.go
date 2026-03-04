package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Permission represents an actionable right (e.g. customers:create, batches:read).
// Used for RBAC; roles are granted one or more permissions.
type Permission struct {
	Base        `gorm:"embedded"`
	Code        string `gorm:"size:64;not null;uniqueIndex:idx_permission_code"`
	Name        string `gorm:"size:128;not null"`
	Description string `gorm:"size:512"`
}

func (Permission) TableName() string {
	return "permissions"
}

func (p *Permission) BeforeCreate(tx *gorm.DB) error {
	if p.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		p.ID = id
	}
	return nil
}
