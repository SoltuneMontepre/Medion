package repository

import (
	"context"

	"backend/internal/model"

	"gorm.io/gorm"
)

type CompanyRepository struct {
	*Repository[model.Company]
}

func NewCompanyRepository(db *gorm.DB) *CompanyRepository {
	return &CompanyRepository{Repository: NewRepository[model.Company](db)}
}

// FindAll returns all active companies (for dropdown). Ordered by name.
func (r *CompanyRepository) FindAll(ctx context.Context) ([]model.Company, error) {
	var list []model.Company
	err := r.DB().WithContext(ctx).Where("active = ?", true).Order("name ASC").Find(&list).Error
	return list, err
}
