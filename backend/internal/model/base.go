package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Base struct {
	ID        uuid.UUID       `gorm:"type:uuid;primaryKey"`
	CreatedAt time.Time       `gorm:"autoCreateTime"`
	CreatedBy uuid.UUID       `gorm:"type:uuid"`
	UpdatedAt time.Time       `gorm:"autoUpdateTime"`
	UpdatedBy uuid.UUID       `gorm:"type:uuid"`
	DeletedAt gorm.DeletedAt  `gorm:"index"`
	DeletedBy *uuid.UUID      `gorm:"type:uuid"`
}
