package repository

import (
	"context"

	"backend/internal/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type IngredientRepository struct {
	*Repository[model.Ingredient]
}

func NewIngredientRepository(db *gorm.DB) *IngredientRepository {
	return &IngredientRepository{Repository: NewRepository[model.Ingredient](db)}
}

// ExistsByCode returns true if an ingredient with the given code exists.
func (r *IngredientRepository) ExistsByCode(ctx context.Context, code string) (bool, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Ingredient{}).
		Where("code = ?", code).Count(&count).Error
	return count > 0, err
}

// ExistsByCodeExcludingID returns true if another ingredient (excluding id) has the code.
func (r *IngredientRepository) ExistsByCodeExcludingID(ctx context.Context, code string, id uuid.UUID) (bool, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Ingredient{}).
		Where("code = ? AND id != ?", code, id).Count(&count).Error
	return count > 0, err
}

// SearchByCodeName returns ingredients matching query (code or name), limit 20.
func (r *IngredientRepository) SearchByCodeName(ctx context.Context, query string, limit int) ([]model.Ingredient, error) {
	if limit <= 0 {
		limit = 20
	}
	q := "%" + query + "%"
	var list []model.Ingredient
	err := r.DB().WithContext(ctx).Where(
		"code ILIKE ? OR name ILIKE ?",
		q, q,
	).Limit(limit).Find(&list).Error
	return list, err
}

// FindAll returns ingredients with pagination, ordered by code.
func (r *IngredientRepository) FindAll(ctx context.Context, limit, offset int) ([]model.Ingredient, error) {
	var list []model.Ingredient
	err := r.DB().WithContext(ctx).Order("code ASC").Limit(limit).Offset(offset).Find(&list).Error
	return list, err
}

// Count returns total number of ingredients.
func (r *IngredientRepository) Count(ctx context.Context) (int64, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Ingredient{}).Count(&count).Error
	return count, err
}
