package repository

import (
	"context"

	"backend/internal/model"

	"gorm.io/gorm"
)

type ProductRepository struct {
	*Repository[model.Product]
}

func NewProductRepository(db *gorm.DB) *ProductRepository {
	return &ProductRepository{Repository: NewRepository[model.Product](db)}
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
