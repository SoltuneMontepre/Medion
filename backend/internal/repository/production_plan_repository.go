package repository

import (
	"context"
	"time"

	"backend/internal/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ProductionPlanRepository struct {
	*Repository[model.ProductionPlan]
	db *gorm.DB
}

func NewProductionPlanRepository(db *gorm.DB) *ProductionPlanRepository {
	return &ProductionPlanRepository{Repository: NewRepository[model.ProductionPlan](db), db: db}
}

// FindByPlanDate returns the production plan for the given date (at most one per day).
func (r *ProductionPlanRepository) FindByPlanDate(ctx context.Context, planDate time.Time) (*model.ProductionPlan, error) {
	day := time.Date(planDate.Year(), planDate.Month(), planDate.Day(), 0, 0, 0, 0, time.UTC)
	var plan model.ProductionPlan
	err := r.DB().WithContext(ctx).Where("plan_date = ?", day).First(&plan).Error
	if err != nil {
		return nil, err
	}
	return &plan, nil
}

// ExistsByPlanDate returns true if a plan exists for the given date.
func (r *ProductionPlanRepository) ExistsByPlanDate(ctx context.Context, planDate time.Time) (bool, error) {
	day := time.Date(planDate.Year(), planDate.Month(), planDate.Day(), 0, 0, 0, 0, time.UTC)
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.ProductionPlan{}).Where("plan_date = ?", day).Count(&count).Error
	return count > 0, err
}

// FindByIDWithItems returns the plan with items and product preloaded.
func (r *ProductionPlanRepository) FindByIDWithItems(ctx context.Context, id uuid.UUID) (*model.ProductionPlan, error) {
	var plan model.ProductionPlan
	err := r.DB().WithContext(ctx).Preload("Items", func(db *gorm.DB) *gorm.DB {
		return db.Order("production_plan_items.ordinal ASC")
	}).Preload("Items.Product").First(&plan, "id = ?", id).Error
	if err != nil {
		return nil, err
	}
	return &plan, nil
}

// FindByPlanDateWithItems returns the plan for the given date with items and product preloaded.
func (r *ProductionPlanRepository) FindByPlanDateWithItems(ctx context.Context, planDate time.Time) (*model.ProductionPlan, error) {
	day := time.Date(planDate.Year(), planDate.Month(), planDate.Day(), 0, 0, 0, 0, time.UTC)
	var plan model.ProductionPlan
	err := r.DB().WithContext(ctx).Where("plan_date = ?", day).
		Preload("Items", func(db *gorm.DB) *gorm.DB {
			return db.Order("production_plan_items.ordinal ASC")
		}).Preload("Items.Product").First(&plan).Error
	if err != nil {
		return nil, err
	}
	return &plan, nil
}
