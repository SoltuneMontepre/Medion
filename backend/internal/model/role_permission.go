package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// RolePermission links a role to a permission (many-to-many with audit).
type RolePermission struct {
	Base         `gorm:"embedded"`
	RoleID       uuid.UUID `gorm:"type:uuid;not null;uniqueIndex:idx_role_permission"`
	PermissionID uuid.UUID `gorm:"type:uuid;not null;uniqueIndex:idx_role_permission"`

	Role       Role       `gorm:"foreignKey:RoleID"`
	Permission Permission `gorm:"foreignKey:PermissionID"`
}

func (RolePermission) TableName() string {
	return "role_permissions"
}

func (rp *RolePermission) BeforeCreate(tx *gorm.DB) error {
	if rp.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		rp.ID = id
	}
	return nil
}
