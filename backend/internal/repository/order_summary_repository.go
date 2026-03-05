package repository

import (
	"context"
	"errors"
	"time"

	"backend/internal/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type OrderSummaryRepository struct {
	*Repository[model.OrderSummary]
	db *gorm.DB
}

func NewOrderSummaryRepository(db *gorm.DB) *OrderSummaryRepository {
	return &OrderSummaryRepository{Repository: NewRepository[model.OrderSummary](db), db: db}
}

// FindAll returns all order summaries with pagination (no owner filter; used for admin).
func (r *OrderSummaryRepository) FindAll(ctx context.Context, limit, offset int) ([]model.OrderSummary, error) {
	var list []model.OrderSummary
	err := r.DB().WithContext(ctx).Order("summary_date DESC").Limit(limit).Offset(offset).Find(&list).Error
	return list, err
}

// Count returns total order summaries (no owner filter; used for admin).
func (r *OrderSummaryRepository) Count(ctx context.Context) (int64, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.OrderSummary{}).Count(&count).Error
	return count, err
}

// FindAllByOwnerID returns summaries for the given sale admin (owner), paginated.
func (r *OrderSummaryRepository) FindAllByOwnerID(ctx context.Context, ownerID uuid.UUID, limit, offset int) ([]model.OrderSummary, error) {
	var list []model.OrderSummary
	err := r.DB().WithContext(ctx).Where("owner_id = ?", ownerID).
		Order("summary_date DESC").Limit(limit).Offset(offset).Find(&list).Error
	return list, err
}

// CountByOwnerID returns total count for the given owner.
func (r *OrderSummaryRepository) CountByOwnerID(ctx context.Context, ownerID uuid.UUID) (int64, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.OrderSummary{}).
		Where("owner_id = ?", ownerID).Count(&count).Error
	return count, err
}

// FindAllByOwnerIDIn returns summaries for any of the given owners, paginated (e.g. self + subordinates).
func (r *OrderSummaryRepository) FindAllByOwnerIDIn(ctx context.Context, ownerIDs []uuid.UUID, limit, offset int) ([]model.OrderSummary, error) {
	if len(ownerIDs) == 0 {
		return nil, nil
	}
	var list []model.OrderSummary
	err := r.DB().WithContext(ctx).Where("owner_id IN ?", ownerIDs).
		Order("summary_date DESC").Limit(limit).Offset(offset).Find(&list).Error
	return list, err
}

// CountByOwnerIDIn returns total count for any of the given owners.
func (r *OrderSummaryRepository) CountByOwnerIDIn(ctx context.Context, ownerIDs []uuid.UUID) (int64, error) {
	if len(ownerIDs) == 0 {
		return 0, nil
	}
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.OrderSummary{}).
		Where("owner_id IN ?", ownerIDs).Count(&count).Error
	return count, err
}

// FindBySummaryDateAndOwner returns the summary for the given date and owner (e.g. "today" for this sale admin).
func (r *OrderSummaryRepository) FindBySummaryDateAndOwner(ctx context.Context, t time.Time, ownerID uuid.UUID) (*model.OrderSummary, error) {
	day := time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC)
	var os model.OrderSummary
	err := r.DB().WithContext(ctx).Where("summary_date = ? AND owner_id = ?", day, ownerID).First(&os).Error
	if err != nil {
		return nil, err
	}
	return &os, nil
}

// FindOrCreateByDateAndOwner returns the order summary for the given date and owner; creates it if not found.
func (r *OrderSummaryRepository) FindOrCreateByDateAndOwner(ctx context.Context, summaryDate time.Time, ownerID uuid.UUID) (*model.OrderSummary, error) {
	day := time.Date(summaryDate.Year(), summaryDate.Month(), summaryDate.Day(), 0, 0, 0, 0, time.UTC)
	existing, err := r.FindBySummaryDateAndOwner(ctx, day, ownerID)
	if err == nil {
		return existing, nil
	}
	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}
	os := model.OrderSummary{OwnerID: ownerID, SummaryDate: day}
	if err := r.DB().WithContext(ctx).Create(&os).Error; err != nil {
		return nil, err
	}
	return &os, nil
}

// FindByIDWithItems returns order summary with Items and Product preloaded.
func (r *OrderSummaryRepository) FindByIDWithItems(ctx context.Context, id uuid.UUID) (*model.OrderSummary, error) {
	var os model.OrderSummary
	err := r.DB().WithContext(ctx).Preload("Items.Product").First(&os, "id = ?", id).Error
	if err != nil {
		return nil, err
	}
	return &os, nil
}
