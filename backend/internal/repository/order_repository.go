package repository

import (
	"context"
	"time"

	"backend/internal/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type OrderRepository struct {
	*Repository[model.Order]
	db *gorm.DB
}

func NewOrderRepository(db *gorm.DB) *OrderRepository {
	return &OrderRepository{Repository: NewRepository[model.Order](db), db: db}
}

// CountByCustomerAndDate counts orders for customer on the given date (UTC day).
func (r *OrderRepository) CountByCustomerAndDate(ctx context.Context, customerID uuid.UUID, t time.Time) (int64, error) {
	start := time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
	end := start.AddDate(0, 0, 1)
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Order{}).
		Where("customer_id = ? AND order_date >= ? AND order_date < ?", customerID, start, end).
		Count(&count).Error
	return count, err
}

// FindByCustomerAndDate returns the first order for customer on the given date (if any).
func (r *OrderRepository) FindByCustomerAndDate(ctx context.Context, customerID uuid.UUID, t time.Time) (*model.Order, error) {
	start := time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
	end := start.AddDate(0, 0, 1)
	var o model.Order
	err := r.DB().WithContext(ctx).Where(
		"customer_id = ? AND order_date >= ? AND order_date < ?",
		customerID, start, end,
	).First(&o).Error
	if err != nil {
		return nil, err
	}
	return &o, nil
}

// CountByDatePrefix counts orders with order_number like "DHYYYYMMDD-%" on the given date.
func (r *OrderRepository) CountByDatePrefix(ctx context.Context, prefix string) (int64, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Order{}).
		Where("order_number LIKE ?", prefix+"%").Count(&count).Error
	return count, err
}

// FindAll orders with pagination (Customer preloaded).
func (r *OrderRepository) FindAll(ctx context.Context, limit, offset int) ([]model.Order, error) {
	var list []model.Order
	err := r.DB().WithContext(ctx).Preload("Customer").Order("created_at DESC").Limit(limit).Offset(offset).Find(&list).Error
	return list, err
}

// Count total orders.
func (r *OrderRepository) Count(ctx context.Context) (int64, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Order{}).Count(&count).Error
	return count, err
}
