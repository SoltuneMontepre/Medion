package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Role represents a named set of permissions (e.g. Admin, Operator, Viewer).
// Users get permissions by being assigned one or more roles.
// ParentRoleID defines role hierarchy: child roles can inherit permissions from parent (e.g. Sale Director > Sale Admin > Sale Person).
type Role struct {
	Base        `gorm:"embedded"`
	Code        string `gorm:"size:64;not null;uniqueIndex:idx_role_code"`
	Name        string `gorm:"size:128;not null"`
	Description string `gorm:"size:512"`

	// ParentRoleID: optional parent in role hierarchy. Used for permission inheritance and org structure.
	ParentRoleID *uuid.UUID `gorm:"type:uuid;index:idx_role_parent"`

	RolePermissions []RolePermission `gorm:"foreignKey:RoleID"`
	ParentRole      *Role            `gorm:"foreignKey:ParentRoleID"`
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
