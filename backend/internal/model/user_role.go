package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// UserRole links a user to a role (many-to-many with audit).
type UserRole struct {
	Base   `gorm:"embedded"`
	UserID uuid.UUID `gorm:"type:uuid;not null;uniqueIndex:idx_user_role"`
	RoleID uuid.UUID `gorm:"type:uuid;not null;uniqueIndex:idx_user_role"`

	User User `gorm:"foreignKey:UserID"`
	Role Role `gorm:"foreignKey:RoleID"`
}

func (UserRole) TableName() string {
	return "user_roles"
}

func (ur *UserRole) BeforeCreate(tx *gorm.DB) error {
	if ur.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		ur.ID = id
	}
	return nil
}
