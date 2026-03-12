package repository

import (
	"context"
	"strings"
	"time"

	"backend/internal/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// ListOrdersFilter holds optional filters and sort for order list.
type ListOrdersFilter struct {
	Search       string     // search in customer name and order number (trimmed, optional)
	OrderDateFrom *time.Time // inclusive start of day
	OrderDateTo   *time.Time // inclusive end of day
	Status       string     // exact status (optional)
	SortBy       string     // "created_at", "order_date", "order_number"
	SortOrder    string     // "asc", "desc"
}

type OrderRepository struct {
	*Repository[model.Order]
	db *gorm.DB
}

func NewOrderRepository(db *gorm.DB) *OrderRepository {
	return &OrderRepository{Repository: NewRepository[model.Order](db), db: db}
}

// CountByCustomerAndDate counts orders for customer on the given date (UTC day).
func (r *OrderRepository) CountByCustomerAndDate(ctx context.Context, customerID uuid.UUID, t time.Time) (int64, error) {
	start := time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
	end := start.AddDate(0, 0, 1)
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Order{}).
		Where("customer_id = ? AND order_date >= ? AND order_date < ?", customerID, start, end).
		Count(&count).Error
	return count, err
}

// FindByCustomerAndDate returns the first order for customer on the given date (if any).
func (r *OrderRepository) FindByCustomerAndDate(ctx context.Context, customerID uuid.UUID, t time.Time) (*model.Order, error) {
	start := time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
	end := start.AddDate(0, 0, 1)
	var o model.Order
	err := r.DB().WithContext(ctx).Where(
		"customer_id = ? AND order_date >= ? AND order_date < ?",
		customerID, start, end,
	).First(&o).Error
	if err != nil {
		return nil, err
	}
	return &o, nil
}

// CountByDatePrefix counts orders with order_number like "DHYYYYMMDD-%" on the given date.
func (r *OrderRepository) CountByDatePrefix(ctx context.Context, prefix string) (int64, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Order{}).
		Where("order_number LIKE ?", prefix+"%").Count(&count).Error
	return count, err
}

// FindAll orders with pagination (Customer preloaded).
func (r *OrderRepository) FindAll(ctx context.Context, limit, offset int) ([]model.Order, error) {
	var list []model.Order
	err := r.DB().WithContext(ctx).Preload("Customer").Order("created_at DESC").Limit(limit).Offset(offset).Find(&list).Error
	return list, err
}

// FindAllByCreatedBy returns orders created by the given user (sale person: own orders).
func (r *OrderRepository) FindAllByCreatedBy(ctx context.Context, createdBy uuid.UUID, limit, offset int) ([]model.Order, error) {
	var list []model.Order
	err := r.DB().WithContext(ctx).Where("created_by = ?", createdBy).
		Preload("Customer").Order("created_at DESC").Limit(limit).Offset(offset).Find(&list).Error
	return list, err
}

// CountByCreatedBy returns total orders created by the given user.
func (r *OrderRepository) CountByCreatedBy(ctx context.Context, createdBy uuid.UUID) (int64, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Order{}).Where("created_by = ?", createdBy).Count(&count).Error
	return count, err
}

// FindAllByCreatedByIn returns orders created by any of the given users (sale admin: team orders).
func (r *OrderRepository) FindAllByCreatedByIn(ctx context.Context, createdByIDs []uuid.UUID, limit, offset int) ([]model.Order, error) {
	if len(createdByIDs) == 0 {
		return nil, nil
	}
	var list []model.Order
	err := r.DB().WithContext(ctx).Where("created_by IN ?", createdByIDs).
		Preload("Customer").Order("created_at DESC").Limit(limit).Offset(offset).Find(&list).Error
	return list, err
}

// CountByCreatedByIn returns total orders created by any of the given users.
func (r *OrderRepository) CountByCreatedByIn(ctx context.Context, createdByIDs []uuid.UUID) (int64, error) {
	if len(createdByIDs) == 0 {
		return 0, nil
	}
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Order{}).Where("created_by IN ?", createdByIDs).Count(&count).Error
	return count, err
}

// Count total orders.
func (r *OrderRepository) Count(ctx context.Context) (int64, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Order{}).Count(&count).Error
	return count, err
}

// FindWithFilters returns orders with optional filters and sort; creatorIDs nil = all (admin), non-nil = scope by created_by.
func (r *OrderRepository) FindWithFilters(ctx context.Context, filter ListOrdersFilter, creatorIDs []uuid.UUID, limit, offset int) ([]model.Order, error) {
	q := r.DB().WithContext(ctx).Model(&model.Order{})
	if len(creatorIDs) > 0 {
		q = q.Where("orders.created_by IN ?", creatorIDs)
	}
	// Search: customer name or order number (case-insensitive)
	if filter.Search != "" {
		search := "%" + strings.TrimSpace(filter.Search) + "%"
		q = q.Joins("LEFT JOIN customers ON customers.id = orders.customer_id").
			Where("LOWER(orders.order_number) LIKE LOWER(?) OR LOWER(customers.name) LIKE LOWER(?)", search, search)
	}
	if filter.OrderDateFrom != nil {
		q = q.Where("orders.order_date >= ?", *filter.OrderDateFrom)
	}
	if filter.OrderDateTo != nil {
		q = q.Where("orders.order_date <= ?", *filter.OrderDateTo)
	}
	if filter.Status != "" {
		q = q.Where("orders.status = ?", strings.TrimSpace(filter.Status))
	}
	orderCol := "orders.created_at"
	switch strings.TrimSpace(filter.SortBy) {
	case "order_date":
		orderCol = "orders.order_date"
	case "order_number":
		orderCol = "orders.order_number"
	default:
		orderCol = "orders.created_at"
	}
	orderDir := "DESC"
	if strings.TrimSpace(filter.SortOrder) == "asc" {
		orderDir = "ASC"
	}
	q = q.Order(orderCol + " " + orderDir).Limit(limit).Offset(offset)
	// Select orders.* so JOIN with customers does not duplicate columns when scanning into Order
	if filter.Search != "" {
		q = q.Select("orders.*")
	}
	var list []model.Order
	err := q.Preload("Customer").Find(&list).Error
	return list, err
}

// CountWithFilters returns total count with the same filters (no limit/offset).
func (r *OrderRepository) CountWithFilters(ctx context.Context, filter ListOrdersFilter, creatorIDs []uuid.UUID) (int64, error) {
	q := r.DB().WithContext(ctx).Model(&model.Order{})
	if len(creatorIDs) > 0 {
		q = q.Where("orders.created_by IN ?", creatorIDs)
	}
	if filter.Search != "" {
		search := "%" + strings.TrimSpace(filter.Search) + "%"
		q = q.Joins("LEFT JOIN customers ON customers.id = orders.customer_id").
			Where("LOWER(orders.order_number) LIKE LOWER(?) OR LOWER(customers.name) LIKE LOWER(?)", search, search)
	}
	if filter.OrderDateFrom != nil {
		q = q.Where("orders.order_date >= ?", *filter.OrderDateFrom)
	}
	if filter.OrderDateTo != nil {
		q = q.Where("orders.order_date <= ?", *filter.OrderDateTo)
	}
	if filter.Status != "" {
		q = q.Where("orders.status = ?", strings.TrimSpace(filter.Status))
	}
	var count int64
	err := q.Count(&count).Error
	return count, err
}
