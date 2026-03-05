package repository

import (
	"context"

	"backend/internal/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type DepartmentRepository struct {
	*Repository[model.Department]
}

func NewDepartmentRepository(db *gorm.DB) *DepartmentRepository {
	return &DepartmentRepository{Repository: NewRepository[model.Department](db)}
}

// FindAll returns departments with optional company filter, paginated. Preloads Company.
func (r *DepartmentRepository) FindAll(ctx context.Context, companyID *uuid.UUID, limit, offset int) ([]model.Department, error) {
	q := r.DB().WithContext(ctx).Preload("Company").Order("code ASC").Limit(limit).Offset(offset)
	if companyID != nil && *companyID != uuid.Nil {
		q = q.Where("company_id = ?", *companyID)
	}
	var list []model.Department
	err := q.Find(&list).Error
	return list, err
}

// Count returns total departments, optionally filtered by company.
func (r *DepartmentRepository) Count(ctx context.Context, companyID *uuid.UUID) (int64, error) {
	q := r.DB().WithContext(ctx).Model(&model.Department{})
	if companyID != nil && *companyID != uuid.Nil {
		q = q.Where("company_id = ?", *companyID)
	}
	var count int64
	err := q.Count(&count).Error
	return count, err
}

// ExistsByCompanyIDAndCode returns true if a department with the given code exists in the company.
func (r *DepartmentRepository) ExistsByCompanyIDAndCode(ctx context.Context, companyID uuid.UUID, code string) (bool, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Department{}).
		Where("company_id = ? AND code = ?", companyID, code).Count(&count).Error
	return count > 0, err
}

// ExistsByCompanyIDAndCodeExcludingID returns true if another department (excluding id) has the same code in the company.
func (r *DepartmentRepository) ExistsByCompanyIDAndCodeExcludingID(ctx context.Context, companyID uuid.UUID, code, excludeID string) (bool, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Department{}).
		Where("company_id = ? AND code = ? AND id != ?", companyID, code, excludeID).Count(&count).Error
	return count > 0, err
}

// FindByCompanyID returns all departments of a company (for dropdown). Preloads Company.
func (r *DepartmentRepository) FindByCompanyID(ctx context.Context, companyID uuid.UUID) ([]model.Department, error) {
	var list []model.Department
	err := r.DB().WithContext(ctx).Preload("Company").Where("company_id = ?", companyID).Order("code ASC").Find(&list).Error
	return list, err
}

// FindByIDWithCompany loads a department by ID with Company preloaded.
func (r *DepartmentRepository) FindByIDWithCompany(ctx context.Context, id string) (*model.Department, error) {
	var d model.Department
	if err := r.DB().WithContext(ctx).Preload("Company").First(&d, "id = ?", id).Error; err != nil {
		return nil, err
	}
	return &d, nil
}
