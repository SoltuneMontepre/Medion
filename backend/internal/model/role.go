package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Role represents a named set of permissions (e.g. Admin, Operator, Viewer).
// Users get permissions by being assigned one or more roles.
type Role struct {
	Base        `gorm:"embedded"`
	Code        string `gorm:"size:64;not null;uniqueIndex:idx_role_code"`
	Name        string `gorm:"size:128;not null"`
	Description string `gorm:"size:512"`

	RolePermissions []RolePermission `gorm:"foreignKey:RoleID"`
}

func (Role) TableName() string {
	return "roles"
}

func (r *Role) BeforeCreate(tx *gorm.DB) error {
	if r.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		r.ID = id
	}
	return nil
}
