package repository

import (
	"context"

	"backend/internal/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type FinishedProductDispatchRepository struct {
	*Repository[model.FinishedProductDispatch]
	db *gorm.DB
}

func NewFinishedProductDispatchRepository(db *gorm.DB) *FinishedProductDispatchRepository {
	return &FinishedProductDispatchRepository{Repository: NewRepository[model.FinishedProductDispatch](db), db: db}
}

// FindByIDWithItems returns the dispatch with items and customer/product preloaded.
func (r *FinishedProductDispatchRepository) FindByIDWithItems(ctx context.Context, id uuid.UUID) (*model.FinishedProductDispatch, error) {
	var d model.FinishedProductDispatch
	err := r.DB().WithContext(ctx).
		Preload("Customer").
		Preload("Items", func(db *gorm.DB) *gorm.DB {
			return db.Order("finished_product_dispatch_lines.ordinal ASC")
		}).
		Preload("Items.Product").
		First(&d, "id = ?", id).Error
	if err != nil {
		return nil, err
	}
	return &d, nil
}

// List returns dispatches with items/customer/product, optional status filter, ordered by created_at desc.
func (r *FinishedProductDispatchRepository) List(ctx context.Context, status string, limit, offset int) ([]model.FinishedProductDispatch, error) {
	q := r.DB().WithContext(ctx).
		Preload("Customer").
		Preload("Items", func(db *gorm.DB) *gorm.DB {
			return db.Order("finished_product_dispatch_lines.ordinal ASC")
		}).
		Preload("Items.Product").
		Order("created_at DESC").Limit(limit).Offset(offset)
	if status != "" {
		q = q.Where("status = ?", status)
	}
	var list []model.FinishedProductDispatch
	err := q.Find(&list).Error
	return list, err
}

// Count returns total count, optional status filter.
func (r *FinishedProductDispatchRepository) Count(ctx context.Context, status string) (int64, error) {
	q := r.DB().WithContext(ctx).Model(&model.FinishedProductDispatch{})
	if status != "" {
		q = q.Where("status = ?", status)
	}
	var n int64
	err := q.Count(&n).Error
	return n, err
}
