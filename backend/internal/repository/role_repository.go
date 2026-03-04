package repository

import (
	"context"

	"backend/internal/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type RoleRepository struct {
	*Repository[model.Role]
	db *gorm.DB
}

func NewRoleRepository(db *gorm.DB) *RoleRepository {
	return &RoleRepository{Repository: NewRepository[model.Role](db), db: db}
}

// FindAll returns roles with ParentRole preloaded, ordered by code.
func (r *RoleRepository) FindAll(ctx context.Context, limit, offset int) ([]model.Role, error) {
	var list []model.Role
	err := r.DB().WithContext(ctx).
		Preload("ParentRole").
		Order("code ASC").
		Limit(limit).Offset(offset).
		Find(&list).Error
	return list, err
}

// FindAllNoPaging returns all roles with ParentRole preloaded (for hierarchy display).
func (r *RoleRepository) FindAllNoPaging(ctx context.Context) ([]model.Role, error) {
	var list []model.Role
	err := r.DB().WithContext(ctx).
		Preload("ParentRole").
		Order("code ASC").
		Find(&list).Error
	return list, err
}

// Count returns total number of roles.
func (r *RoleRepository) Count(ctx context.Context) (int64, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Role{}).Count(&count).Error
	return count, err
}

// FindByCode returns role by code.
func (r *RoleRepository) FindByCode(ctx context.Context, code string) (*model.Role, error) {
	var role model.Role
	err := r.DB().WithContext(ctx).Where("code = ?", code).First(&role).Error
	if err != nil {
		return nil, err
	}
	return &role, nil
}

// ExistsByCode returns true if a role with the given code exists.
func (r *RoleRepository) ExistsByCode(ctx context.Context, code string) (bool, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Role{}).
		Where("code = ?", code).Count(&count).Error
	return count > 0, err
}

// ExistsByCodeExcludingID returns true if another role (excluding id) has the code.
func (r *RoleRepository) ExistsByCodeExcludingID(ctx context.Context, code string, id uuid.UUID) (bool, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Role{}).
		Where("code = ? AND id != ?", code, id).Count(&count).Error
	return count > 0, err
}

// HasUserAssignments returns true if any user has this role (user_roles.role_id = id).
func (r *RoleRepository) HasUserAssignments(ctx context.Context, roleID uuid.UUID) (bool, error) {
	var count int64
	err := r.DB().WithContext(ctx).Table("user_roles").
		Where("role_id = ?", roleID).Count(&count).Error
	return count > 0, err
}

// CountChildren returns number of roles that have this role as parent.
func (r *RoleRepository) CountChildren(ctx context.Context, parentID uuid.UUID) (int64, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.Role{}).
		Where("parent_role_id = ?", parentID).Count(&count).Error
	return count, err
}
