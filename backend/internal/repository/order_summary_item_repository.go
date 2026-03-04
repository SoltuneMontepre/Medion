package repository

import (
	"context"
	"errors"

	"backend/internal/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type OrderSummaryItemRepository struct {
	*Repository[model.OrderSummaryItem]
	db *gorm.DB
}

func NewOrderSummaryItemRepository(db *gorm.DB) *OrderSummaryItemRepository {
	return &OrderSummaryItemRepository{Repository: NewRepository[model.OrderSummaryItem](db), db: db}
}

// CreateBatch creates multiple order summary items.
func (r *OrderSummaryItemRepository) CreateBatch(ctx context.Context, orderSummaryID uuid.UUID, items []model.OrderSummaryItem) error {
	for i := range items {
		items[i].OrderSummaryID = orderSummaryID
	}
	return r.DB().WithContext(ctx).Create(&items).Error
}

// FindByOrderSummaryID returns all items for an order summary (with Product preload).
func (r *OrderSummaryItemRepository) FindByOrderSummaryID(ctx context.Context, orderSummaryID uuid.UUID) ([]model.OrderSummaryItem, error) {
	var list []model.OrderSummaryItem
	err := r.DB().WithContext(ctx).Where("order_summary_id = ?", orderSummaryID).
		Preload("Product").Find(&list).Error
	return list, err
}

// CountByOrderSummaryID returns the number of items for an order summary.
func (r *OrderSummaryItemRepository) CountByOrderSummaryID(ctx context.Context, orderSummaryID uuid.UUID) (int64, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.OrderSummaryItem{}).
		Where("order_summary_id = ?", orderSummaryID).Count(&count).Error
	return count, err
}

// DeleteByOrderSummaryID hard-deletes all items for an order summary (for replace on edit; avoids soft-deleted duplicates).
func (r *OrderSummaryItemRepository) DeleteByOrderSummaryID(ctx context.Context, orderSummaryID uuid.UUID) error {
	return r.DB().WithContext(ctx).Unscoped().Where("order_summary_id = ?", orderSummaryID).
		Delete(&model.OrderSummaryItem{}).Error
}

// FindByOrderSummaryIDAndProductID returns the order summary item for the given summary and product, if any.
func (r *OrderSummaryItemRepository) FindByOrderSummaryIDAndProductID(ctx context.Context, orderSummaryID, productID uuid.UUID) (*model.OrderSummaryItem, error) {
	var osi model.OrderSummaryItem
	err := r.DB().WithContext(ctx).Where("order_summary_id = ? AND product_id = ?", orderSummaryID, productID).First(&osi).Error
	if err != nil {
		return nil, err
	}
	return &osi, nil
}

// AddQuantity adds quantity to the order summary item for (orderSummaryID, productID). Creates the item if it does not exist.
func (r *OrderSummaryItemRepository) AddQuantity(ctx context.Context, orderSummaryID, productID uuid.UUID, addQty int) error {
	existing, err := r.FindByOrderSummaryIDAndProductID(ctx, orderSummaryID, productID)
	if err == nil {
		existing.Quantity += addQty
		return r.DB().WithContext(ctx).Save(existing).Error
	}
	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return err
	}
	osi := model.OrderSummaryItem{OrderSummaryID: orderSummaryID, ProductID: productID, Quantity: addQty}
	return r.DB().WithContext(ctx).Create(&osi).Error
}
