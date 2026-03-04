package database

import (
	"fmt"
	"log"
	"os"

	"backend/internal/model"
	"backend/internal/security"

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
		&model.Customer{},
		&model.Product{},
		&model.Order{},
		&model.OrderItem{},
		&model.OrderSummary{},
		&model.OrderSummaryItem{},
		&model.Permission{},
		&model.Role{},
		&model.RolePermission{},
		&model.UserRole{},
	)
}

// Default seed user for local/dev when no users exist. Safe to call on every startup.
const (
	seedEmail    = "admin@medion.local"
	seedUsername = "admin"
	seedPassword = "MedionAdmin1!"
)

// Sample products for sale order (seed when table is empty).
var seedProducts = []model.Product{
	{Code: "111", Name: "Amox 10%", PackageSize: "100", PackageUnit: "gr", ProductType: "Bột uống", PackagingType: "Gói"},
	{Code: "222", Name: "Ampi 20%", PackageSize: "250", PackageUnit: "gr", ProductType: "Bột uống", PackagingType: "Gói"},
	{Code: "333", Name: "Enro 10%", PackageSize: "100", PackageUnit: "ml", ProductType: "Dung dịch tiêm", PackagingType: "Chai"},
	{Code: "444", Name: "Flor 30%", PackageSize: "1000", PackageUnit: "ml", ProductType: "Dung dịch uống", PackagingType: "Chai"},
	{Code: "555", Name: "Amox hỗn dịch 15%", PackageSize: "100", PackageUnit: "ml", ProductType: "Hỗn dịch tiêm", PackagingType: "Chai"},
	{Code: "666", Name: "Cetriason", PackageSize: "100", PackageUnit: "ml", ProductType: "Bột pha tiêm", PackagingType: "Chai"},
}

// SeedDefaultUser creates a single user (admin@medion.local / MedionAdmin1!) if the users table is empty.
func SeedDefaultUser(db *gorm.DB) error {
	var count int64
	if err := db.Model(&model.User{}).Count(&count).Error; err != nil {
		return err
	}
	if count > 0 {
		return nil
	}
	hashed, err := security.HashPassword(seedPassword)
	if err != nil {
		return fmt.Errorf("seed default user: hash password: %w", err)
	}
	u := model.User{
		Username: seedUsername,
		Email:    seedEmail,
		Password: hashed,
	}
	if err := db.Create(&u).Error; err != nil {
		return fmt.Errorf("seed default user: create: %w", err)
	}
	log.Println("database: seeded default user (admin@medion.local)")
	return nil
}

// SeedProducts creates sample products when the products table is empty.
func SeedProducts(db *gorm.DB) error {
	var count int64
	if err := db.Model(&model.Product{}).Count(&count).Error; err != nil {
		return err
	}
	if count > 0 {
		return nil
	}
	for i := range seedProducts {
		if err := db.Create(&seedProducts[i]).Error; err != nil {
			return err
		}
	}
	log.Println("database: seeded sample products")
	return nil
}

// Order summary permissions (ViewOrderSummary, CreateOrderSummary, EditOrderSummary, DeleteOrderSummary).
var seedOrderSummaryPermissions = []model.Permission{
	{Code: "ViewOrderSummary", Name: "Xem bảng tổng hợp đơn hàng", Description: "View order summary table"},
	{Code: "CreateOrderSummary", Name: "Tạo bảng tổng hợp đơn hàng", Description: "Create order summary table"},
	{Code: "EditOrderSummary", Name: "Sửa bảng tổng hợp đơn hàng", Description: "Edit order summary table"},
	{Code: "DeleteOrderSummary", Name: "Xóa bảng tổng hợp đơn hàng", Description: "Delete order summary table"},
}

// SeedOrderSummaryPermissions creates order summary permissions when missing (by code).
func SeedOrderSummaryPermissions(db *gorm.DB) error {
	for i := range seedOrderSummaryPermissions {
		var existing model.Permission
		err := db.Where("code = ?", seedOrderSummaryPermissions[i].Code).First(&existing).Error
		if err == gorm.ErrRecordNotFound {
			if err := db.Create(&seedOrderSummaryPermissions[i]).Error; err != nil {
				return err
			}
		} else if err != nil {
			return err
		}
	}
	log.Println("database: seeded order summary permissions")
	return nil
}

// Default roles: admin, sale_admin, sale. Safe to call on every startup (creates only when missing by code).
var seedRoles = []model.Role{
	{Code: "admin", Name: "Admin", Description: "Full system administrator"},
	{Code: "sale_admin", Name: "Sale Admin", Description: "Sales administration and oversight"},
	{Code: "sale", Name: "Sale", Description: "Sales person"},
}

// SeedRoles creates default roles (admin, sale_admin, sale) when missing (by code).
func SeedRoles(db *gorm.DB) error {
	for i := range seedRoles {
		var existing model.Role
		err := db.Where("code = ?", seedRoles[i].Code).First(&existing).Error
		if err == gorm.ErrRecordNotFound {
			if err := db.Create(&seedRoles[i]).Error; err != nil {
				return err
			}
		} else if err != nil {
			return err
		}
	}
	log.Println("database: seeded default roles (admin, sale_admin, sale)")
	return nil
}
