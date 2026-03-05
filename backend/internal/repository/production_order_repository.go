package repository

import (
	"context"

	"backend/internal/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ProductionOrderRepository struct {
	*Repository[model.ProductionOrder]
	db *gorm.DB
}

func NewProductionOrderRepository(db *gorm.DB) *ProductionOrderRepository {
	return &ProductionOrderRepository{Repository: NewRepository[model.ProductionOrder](db), db: db}
}

// FindByIDWithProduct returns order with Product preloaded.
func (r *ProductionOrderRepository) FindByIDWithProduct(ctx context.Context, id uuid.UUID) (*model.ProductionOrder, error) {
	var o model.ProductionOrder
	err := r.DB().WithContext(ctx).Preload("Product").First(&o, "id = ?", id).Error
	if err != nil {
		return nil, err
	}
	return &o, nil
}

// List returns orders with Product preloaded, paginated.
func (r *ProductionOrderRepository) List(ctx context.Context, limit, offset int, status string) ([]model.ProductionOrder, int64, error) {
	q := r.DB().WithContext(ctx).Model(&model.ProductionOrder{})
	if status != "" {
		q = q.Where("status = ?", status)
	}
	var total int64
	if err := q.Count(&total).Error; err != nil {
		return nil, 0, err
	}
	var list []model.ProductionOrder
	findQ := r.DB().WithContext(ctx).Preload("Product").Order("created_at DESC").Limit(limit).Offset(offset)
	if status != "" {
		findQ = findQ.Where("status = ?", status)
	}
	err := findQ.Find(&list).Error
	return list, total, err
}

// ExistsByOrderNumber returns true if an order with the given number exists.
func (r *ProductionOrderRepository) ExistsByOrderNumber(ctx context.Context, orderNumber string) (bool, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.ProductionOrder{}).
		Where("order_number = ?", orderNumber).Count(&count).Error
	return count > 0, err
}
