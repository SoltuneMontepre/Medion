package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type User struct {
	Base     `gorm:"embedded"`
	Username string  `gorm:"size:64;not null;uniqueIndex:idx_user_username"`
	Email    string  `gorm:"size:255;not null;uniqueIndex:idx_user_email"`
	Password string  `gorm:"size:255;not null"`
	PIN      *string `gorm:"size:255"`

	UserRoles []UserRole `gorm:"foreignKey:UserID"`
}

func (User) TableName() string {
	return "users"
}

func (u *User) BeforeCreate(tx *gorm.DB) error {
	if u.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		u.ID = id
	}
	return nil
}
