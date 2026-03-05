package repository

import (
	"context"
	"errors"

	"backend/internal/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type InventoryRepository struct {
	*Repository[model.Inventory]
}

func NewInventoryRepository(db *gorm.DB) *InventoryRepository {
	return &InventoryRepository{Repository: NewRepository[model.Inventory](db)}
}

// FindAll returns inventory records with Product preloaded, filtered by warehouseType, paginated.
func (r *InventoryRepository) FindAll(ctx context.Context, warehouseType string, limit, offset int) ([]model.Inventory, error) {
	q := r.DB().WithContext(ctx).Preload("Product").Order("created_at ASC").Limit(limit).Offset(offset)
	if warehouseType != "" {
		q = q.Where("warehouse_type = ?", warehouseType)
	}
	var list []model.Inventory
	err := q.Find(&list).Error
	return list, err
}

// Count returns total inventory records, optionally filtered by warehouseType.
func (r *InventoryRepository) Count(ctx context.Context, warehouseType string) (int64, error) {
	q := r.DB().WithContext(ctx).Model(&model.Inventory{})
	if warehouseType != "" {
		q = q.Where("warehouse_type = ?", warehouseType)
	}
	var count int64
	err := q.Count(&count).Error
	return count, err
}

// FindByIDWithProduct loads inventory by ID with Product preloaded.
func (r *InventoryRepository) FindByIDWithProduct(ctx context.Context, id string) (*model.Inventory, error) {
	var inv model.Inventory
	if err := r.DB().WithContext(ctx).Preload("Product").First(&inv, "id = ?", id).Error; err != nil {
		return nil, err
	}
	return &inv, nil
}

// FindByProductIDAndWarehouseType returns one inventory record for product + warehouse (for upsert/adjust).
func (r *InventoryRepository) FindByProductIDAndWarehouseType(ctx context.Context, productID uuid.UUID, warehouseType string) (*model.Inventory, error) {
	var inv model.Inventory
	if err := r.DB().WithContext(ctx).Where("product_id = ? AND warehouse_type = ?", productID, warehouseType).First(&inv).Error; err != nil {
		return nil, err
	}
	return &inv, nil
}

// AddQuantity adds quantity to finished-product inventory for the given product. Creates the record if it does not exist.
func (r *InventoryRepository) AddQuantity(ctx context.Context, productID uuid.UUID, addQty int64) error {
	inv, err := r.FindByProductIDAndWarehouseType(ctx, productID, model.WarehouseTypeFinished)
	if err == nil {
		inv.Quantity += addQty
		return r.DB().WithContext(ctx).Save(inv).Error
	}
	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return err
	}
	inv = &model.Inventory{
		ProductID:     productID,
		WarehouseType: model.WarehouseTypeFinished,
		Quantity:      addQty,
	}
	return r.DB().WithContext(ctx).Create(inv).Error
}
