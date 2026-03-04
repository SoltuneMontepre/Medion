package repository

import (
	"context"

	"backend/internal/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type OrderItemRepository struct {
	*Repository[model.OrderItem]
	db *gorm.DB
}

func NewOrderItemRepository(db *gorm.DB) *OrderItemRepository {
	return &OrderItemRepository{Repository: NewRepository[model.OrderItem](db), db: db}
}

// CreateBatch creates multiple order items in a transaction.
func (r *OrderItemRepository) CreateBatch(ctx context.Context, orderID uuid.UUID, items []model.OrderItem) error {
	for i := range items {
		items[i].OrderID = orderID
	}
	return r.DB().WithContext(ctx).Create(&items).Error
}

// FindByOrderID returns all items for an order (with Product preload).
func (r *OrderItemRepository) FindByOrderID(ctx context.Context, orderID uuid.UUID) ([]model.OrderItem, error) {
	var list []model.OrderItem
	err := r.DB().WithContext(ctx).Where("order_id = ?", orderID).
		Preload("Product").Find(&list).Error
	return list, err
}
