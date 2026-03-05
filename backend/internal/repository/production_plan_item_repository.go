package repository

import (
	"context"

	"backend/internal/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ProductionPlanItemRepository struct {
	*Repository[model.ProductionPlanItem]
	db *gorm.DB
}

func NewProductionPlanItemRepository(db *gorm.DB) *ProductionPlanItemRepository {
	return &ProductionPlanItemRepository{Repository: NewRepository[model.ProductionPlanItem](db), db: db}
}

// CreateBatch creates multiple production plan items.
func (r *ProductionPlanItemRepository) CreateBatch(ctx context.Context, planID uuid.UUID, items []model.ProductionPlanItem) error {
	for i := range items {
		items[i].ProductionPlanID = planID
	}
	return r.DB().WithContext(ctx).Create(&items).Error
}

// FindByProductionPlanID returns all items for a plan (with Product preload), ordered by ordinal.
func (r *ProductionPlanItemRepository) FindByProductionPlanID(ctx context.Context, planID uuid.UUID) ([]model.ProductionPlanItem, error) {
	var list []model.ProductionPlanItem
	err := r.DB().WithContext(ctx).Where("production_plan_id = ?", planID).
		Preload("Product").Order("ordinal ASC").Find(&list).Error
	return list, err
}

// DeleteByProductionPlanID deletes all items for a plan (for replace on update).
func (r *ProductionPlanItemRepository) DeleteByProductionPlanID(ctx context.Context, planID uuid.UUID) error {
	return r.DB().WithContext(ctx).Where("production_plan_id = ?", planID).
		Delete(&model.ProductionPlanItem{}).Error
}
