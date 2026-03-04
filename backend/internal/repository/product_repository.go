package repository

import (
	"context"

	"backend/internal/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ProductRepository struct {
	*Repository[model.Product]
}

func NewProductRepository(db *gorm.DB) *ProductRepository {
	return &ProductRepository{Repository: NewRepository[model.Product](db)}
}

// ExistsByCode returns true if a product with the given code exists.
func (r *ProductRepository) ExistsByCode(ctx context.Context, code string) (bool, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Product{}).
		Where("code = ?", code).Count(&count).Error
	return count > 0, err
}

// ExistsByCodeExcludingID returns true if another product (excluding id) has the code.
func (r *ProductRepository) ExistsByCodeExcludingID(ctx context.Context, code string, id uuid.UUID) (bool, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Product{}).
		Where("code = ? AND id != ?", code, id).Count(&count).Error
	return count > 0, err
}

// SearchByCodeName returns products matching query (code or name), limit 20.
func (r *ProductRepository) SearchByCodeName(ctx context.Context, query string, limit int) ([]model.Product, error) {
	if limit <= 0 {
		limit = 20
	}
	q := "%" + query + "%"
	var list []model.Product
	err := r.DB().WithContext(ctx).Where(
		"code ILIKE ? OR name ILIKE ?",
		q, q,
	).Limit(limit).Find(&list).Error
	return list, err
}

// FindAll returns products with pagination, ordered by code.
func (r *ProductRepository) FindAll(ctx context.Context, limit, offset int) ([]model.Product, error) {
	var list []model.Product
	err := r.DB().WithContext(ctx).Order("code ASC").Limit(limit).Offset(offset).Find(&list).Error
	return list, err
}

// Count returns total number of products.
func (r *ProductRepository) Count(ctx context.Context) (int64, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Product{}).Count(&count).Error
	return count, err
}
