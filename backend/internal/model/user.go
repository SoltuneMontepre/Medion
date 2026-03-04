package model

type User struct {
	Base     `gorm:"embedded"`
	Username string `gorm:"size:64;not null;uniqueIndex:idx_user_username"`
	Email    string `gorm:"size:255;not null;uniqueIndex:idx_user_email"`
	Password string `gorm:"size:255;not null"`
}

func (User) TableName() string {
	return "users"
}
