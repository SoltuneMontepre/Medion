package database

import (
	"fmt"
	"log"
	"os"

	"backend/internal/model"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

const envDSN = "DATABASE_DSN"

type Config struct {
	DSN      string
	LogLevel logger.LogLevel
}

func Open(cfg Config) (*gorm.DB, error) {
	_ = godotenv.Load()
	dsn := cfg.DSN
	if dsn == "" {
		dsn = os.Getenv(envDSN)
	}
	if dsn == "" {
		return nil, fmt.Errorf("DATABASE_DSN is required (set in .env or environment)")
	}

	logLevel := cfg.LogLevel
	if logLevel == 0 {
		logLevel = logger.Info
	}

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logLevel),
	})
	if err != nil {
		return nil, err
	}

	log.Println("database: connected (postgres)")
	return db, nil
}

func AutoMigrate(db *gorm.DB) error {
	return db.AutoMigrate(
		&model.User{},
	)
}
