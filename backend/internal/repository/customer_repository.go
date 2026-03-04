package repository

import (
	"context"

	"backend/internal/model"

	"gorm.io/gorm"
)

type CustomerRepository struct {
	*Repository[model.Customer]
}

func NewCustomerRepository(db *gorm.DB) *CustomerRepository {
	return &CustomerRepository{Repository: NewRepository[model.Customer](db)}
}

func (r *CustomerRepository) ExistsByPhone(ctx context.Context, phone string) (bool, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Customer{}).Where("phone = ?", phone).Count(&count).Error
	if err != nil {
		return false, err
	}
	return count > 0, nil
}

// ExistsByPhoneExcludingID returns true if another customer (excluding id) has the phone.
func (r *CustomerRepository) ExistsByPhoneExcludingID(ctx context.Context, phone string, excludeID string) (bool, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Customer{}).
		Where("phone = ? AND id != ?", phone, excludeID).Count(&count).Error
	if err != nil {
		return false, err
	}
	return count > 0, nil
}

func (r *CustomerRepository) FindAll(ctx context.Context, limit, offset int) ([]model.Customer, error) {
	var list []model.Customer
	err := r.DB().WithContext(ctx).Order("created_at DESC").Limit(limit).Offset(offset).Find(&list).Error
	if err != nil {
		return nil, err
	}
	return list, nil
}

func (r *CustomerRepository) Count(ctx context.Context) (int64, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Customer{}).Count(&count).Error
	return count, err
}

// SearchByCodeNamePhone returns customers matching query (code, name, or phone), limit 20.
func (r *CustomerRepository) SearchByCodeNamePhone(ctx context.Context, query string, limit int) ([]model.Customer, error) {
	if limit <= 0 {
		limit = 20
	}
	q := "%" + query + "%"
	var list []model.Customer
	err := r.DB().WithContext(ctx).Where(
		"code ILIKE ? OR name ILIKE ? OR phone ILIKE ?",
		q, q, q,
	).Limit(limit).Find(&list).Error
	return list, err
}
