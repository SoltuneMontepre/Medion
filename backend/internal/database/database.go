package database

import (
	"errors"
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
		&model.Company{},
		&model.Department{},
		&model.Customer{},
		&model.Product{},
		&model.Ingredient{},
		&model.Order{},
		&model.OrderItem{},
		&model.OrderSummary{},
		&model.OrderSummaryItem{},
		&model.Inventory{},
		&model.ProductionPlan{},
		&model.ProductionPlanItem{},
		&model.ProductionOrder{},
		&model.ProductionOrderIngredient{},
		&model.FinishedProductDispatch{},
		&model.FinishedProductDispatchLine{},
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

// Sample ingredients (nguyên liệu) for production orders. Seed when table is empty.
var seedIngredients = []model.Ingredient{
	{Code: "KSI01", Name: "FLORFENICOL", Unit: "kg", Description: ""},
	{Code: "KSI05", Name: "TYLOSIN TARTRATE", Unit: "kg", Description: ""},
	{Code: "DD05", Name: "DIMETHYL SULFOXIDE (DMSO)", Unit: "kg", Description: ""},
	{Code: "NC", Name: "Nước cất vừa đủ", Unit: "lít", Description: "Distilled water"},
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

// SeedDefaultUserAdminRole assigns the admin role to the default user (admin@medion.local) if not already assigned.
// Call after SeedRoles. Safe to call on every startup.
func SeedDefaultUserAdminRole(db *gorm.DB) error {
	var u model.User
	if err := db.Where("email = ?", seedEmail).First(&u).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil
		}
		return err
	}
	var role model.Role
	if err := db.Where("code = ?", "admin").First(&role).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil
		}
		return err
	}
	var exist int64
	if err := db.Model(&model.UserRole{}).Where("user_id = ? AND role_id = ?", u.ID, role.ID).Count(&exist).Error; err != nil {
		return err
	}
	if exist > 0 {
		return nil
	}
	ur := model.UserRole{UserID: u.ID, RoleID: role.ID}
	ur.CreatedBy = u.ID
	ur.UpdatedBy = u.ID
	if err := db.Create(&ur).Error; err != nil {
		return fmt.Errorf("assign admin role to default user: %w", err)
	}
	log.Println("database: assigned admin role to default user (admin@medion.local)")
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

// SeedIngredients creates sample ingredients when the ingredients table is empty.
func SeedIngredients(db *gorm.DB) error {
	var count int64
	if err := db.Model(&model.Ingredient{}).Count(&count).Error; err != nil {
		return err
	}
	if count > 0 {
		return nil
	}
	for i := range seedIngredients {
		if err := db.Create(&seedIngredients[i]).Error; err != nil {
			return err
		}
	}
	log.Println("database: seeded sample ingredients")
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

// Default roles. Safe to call on every startup (creates only when missing by code).
var seedRoles = []model.Role{
	{Code: "admin", Name: "Admin", Description: "Full system administrator"},
	// Sales
	{Code: "sale_admin", Name: "Sale Admin", Description: "Sales administration and oversight"},
	{Code: "sale_person", Name: "Sale", Description: "Sales person"},
	// Planning department
	{Code: "ke_hoach_vien", Name: "Nhân viên phòng kế hoạch", Description: "Lập và sửa kế hoạch sản xuất"},
	{Code: "truong_phong_ke_hoach", Name: "Trưởng phòng kế hoạch", Description: "Duyệt kế hoạch sản xuất"},
	// Warehouse
	{Code: "ke_toan_kho", Name: "Kế toán kho", Description: "Tạo và sửa phiếu xuất kho"},
	{Code: "quan_ly_kho", Name: "Quản lý kho", Description: "Duyệt phiếu xuất kho thành phẩm"},
	{Code: "thu_kho_thanh_pham", Name: "Thủ kho thành phẩm", Description: "Thủ kho quản lý kho thành phẩm"},
}

// SeedRoles creates default roles when missing (by code). Safe to call on every startup.
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
	log.Println("database: seeded default roles")
	return nil
}

// SeedDefaultCompany creates a single company "Medion" if the companies table is empty.
func SeedDefaultCompany(db *gorm.DB) error {
	var count int64
	if err := db.Model(&model.Company{}).Count(&count).Error; err != nil {
		return err
	}
	if count > 0 {
		return nil
	}
	c := model.Company{Code: "MEDION", Name: "Medion", Active: true}
	if err := db.Create(&c).Error; err != nil {
		return err
	}
	log.Println("database: seeded default company (Medion)")
	return nil
}

// SeedDepartments creates default departments when the table is empty (under first company).
func SeedDepartments(db *gorm.DB) error {
	var count int64
	if err := db.Model(&model.Department{}).Count(&count).Error; err != nil {
		return err
	}
	if count > 0 {
		return nil
	}
	var company model.Company
	if err := db.Where("active = ?", true).First(&company).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil
		}
		return err
	}
	seedDepts := []model.Department{
		{CompanyID: company.ID, Code: "KE_HOACH", Name: "Phòng Kế hoạch", Description: "Lập và duyệt kế hoạch sản xuất"},
		{CompanyID: company.ID, Code: "KHO", Name: "Phòng Kho", Description: "Quản lý kho NVL, BTP, TP"},
		{CompanyID: company.ID, Code: "KINH_DOANH", Name: "Phòng Kinh doanh", Description: "Bán hàng và đơn hàng"},
		{CompanyID: company.ID, Code: "SAN_XUAT", Name: "Phòng Sản xuất", Description: "Sản xuất"},
	}
	for i := range seedDepts {
		if err := db.Create(&seedDepts[i]).Error; err != nil {
			return err
		}
	}
	log.Println("database: seeded default departments")
	return nil
}

// Seed department users: Phòng kinh doanh (sale, sale admin), Phòng kế hoạch (nhân viên, trưởng phòng).
// Creates users only when missing (by email). Safe to call on every startup.
func SeedDepartmentUsers(db *gorm.DB) error {
	hashed, err := security.HashPassword(seedPassword)
	if err != nil {
		return fmt.Errorf("seed department users: hash password: %w", err)
	}

	var company model.Company
	if err := db.Where("active = ?", true).First(&company).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil
		}
		return err
	}

	type deptRole struct {
		email, username, deptCode, roleCode string
	}
	seeds := []deptRole{
		{"sale@medion.local", "sale", "KINH_DOANH", "sale_person"},
		{"saleadmin@medion.local", "saleadmin", "KINH_DOANH", "sale_admin"},
		{"kehoach@medion.local", "kehoach", "KE_HOACH", "ke_hoach_vien"},
		{"truongphong_kehoach@medion.local", "truongphong_kehoach", "KE_HOACH", "truong_phong_ke_hoach"},
	}

	for _, s := range seeds {
		var existing model.User
		err := db.Where("email = ?", s.email).First(&existing).Error
		if err == nil {
			continue
		}
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			return err
		}

		var dept model.Department
		if err := db.Where("company_id = ? AND code = ?", company.ID, s.deptCode).First(&dept).Error; err != nil {
			return fmt.Errorf("seed department users: department %s: %w", s.deptCode, err)
		}
		var role model.Role
		if err := db.Where("code = ?", s.roleCode).First(&role).Error; err != nil {
			return fmt.Errorf("seed department users: role %s: %w", s.roleCode, err)
		}

		u := model.User{
			Username:     s.username,
			Email:        s.email,
			Password:     hashed,
			DepartmentID: &dept.ID,
		}
		if err := db.Create(&u).Error; err != nil {
			return fmt.Errorf("seed department users: create user %s: %w", s.email, err)
		}
		ur := model.UserRole{UserID: u.ID, RoleID: role.ID}
		ur.CreatedBy = u.ID
		ur.UpdatedBy = u.ID
		if err := db.Create(&ur).Error; err != nil {
			return fmt.Errorf("seed department users: assign role to %s: %w", s.email, err)
		}
		log.Printf("database: seeded department user %s (%s, %s)", s.email, s.deptCode, s.roleCode)
	}
	return nil
}

// SeedInventory creates one inventory record per product for warehouse "finished" (tồn kho TP) when the table is empty.
func SeedInventory(db *gorm.DB) error {
	var count int64
	if err := db.Model(&model.Inventory{}).Count(&count).Error; err != nil {
		return err
	}
	if count > 0 {
		return nil
	}
	var products []model.Product
	if err := db.Find(&products).Error; err != nil {
		return err
	}
	for _, p := range products {
		inv := model.Inventory{
			ProductID:     p.ID,
			WarehouseType: model.WarehouseTypeFinished,
			Quantity:      0,
		}
		if err := db.Create(&inv).Error; err != nil {
			return err
		}
	}
	log.Println("database: seeded inventory (tồn kho TP) for existing products")
	return nil
}
