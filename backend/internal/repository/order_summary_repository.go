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
