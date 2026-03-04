package repository

import (
	"context"

	"backend/internal/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Repository[T any] struct {
	db *gorm.DB
}

func NewRepository[T any](db *gorm.DB) *Repository[T] {
	return &Repository[T]{db: db}
}

func (r *Repository[T]) DB() *gorm.DB {
	return r.db
}

func (r *Repository[T]) FindByID(ctx context.Context, id any) (*T, error) {
	var entity T
	if err := r.db.WithContext(ctx).First(&entity, "id = ?", id).Error; err != nil {
		return nil, err
	}
	return &entity, nil
}

func (r *Repository[T]) Create(ctx context.Context, entity *T) error {
	return r.db.WithContext(ctx).Create(entity).Error
}

func (r *Repository[T]) Update(ctx context.Context, entity *T) error {
	return r.db.WithContext(ctx).Save(entity).Error
}

func (r *Repository[T]) Delete(ctx context.Context, id any) error {
	var entity T
	return r.db.WithContext(ctx).Delete(&entity, "id = ?", id).Error
}

type UserRepository struct {
	*Repository[model.User]
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{Repository: NewRepository[model.User](db)}
}

func (r *UserRepository) ExistsByEmail(ctx context.Context, email string) (bool, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.User{}).Where("email = ?", email).Count(&count).Error
	if err != nil {
		return false, err
	}
	return count > 0, nil
}

func (r *UserRepository) ExistsByUsername(ctx context.Context, username string) (bool, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.User{}).Where("username = ?", username).Count(&count).Error
	if err != nil {
		return false, err
	}
	return count > 0, nil
}

func (r *UserRepository) FindByEmail(ctx context.Context, email string) (*model.User, error) {
	var user model.User
	if err := r.DB().WithContext(ctx).Where("email = ?", email).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

// GetRoleCodesForUser returns role codes for the user (from user_roles + roles).
func (r *UserRepository) GetRoleCodesForUser(ctx context.Context, userID uuid.UUID) ([]string, error) {
	var codes []string
	err := r.DB().WithContext(ctx).Table("user_roles").
		Select("roles.code").
		Joins("JOIN roles ON roles.id = user_roles.role_id").
		Where("user_roles.user_id = ?", userID).
		Pluck("roles.code", &codes).Error
	return codes, err
}

// FindUserIDsByRoleCode returns user IDs that have the given role (by code).
func (r *UserRepository) FindUserIDsByRoleCode(ctx context.Context, roleCode string) ([]uuid.UUID, error) {
	var ids []uuid.UUID
	err := r.DB().WithContext(ctx).Table("user_roles").
		Select("user_roles.user_id").
		Joins("JOIN roles ON roles.id = user_roles.role_id").
		Where("roles.code = ?", roleCode).
		Pluck("user_roles.user_id", &ids).Error
	return ids, err
}

// FindAll returns users with optional pagination (limit/offset). Ordered by username. Preloads Supervisor.
func (r *UserRepository) FindAll(ctx context.Context, limit, offset int) ([]model.User, error) {
	var list []model.User
	err := r.DB().WithContext(ctx).Preload("Supervisor").Order("username ASC").Limit(limit).Offset(offset).Find(&list).Error
	return list, err
}

// FindDirectSubordinateIDs returns user IDs whose supervisor_id is the given user (direct reports).
func (r *UserRepository) FindDirectSubordinateIDs(ctx context.Context, supervisorID uuid.UUID) ([]uuid.UUID, error) {
	var ids []uuid.UUID
	err := r.DB().WithContext(ctx).Model(&model.User{}).
		Where("supervisor_id = ?", supervisorID).
		Pluck("id", &ids).Error
	return ids, err
}

// GetSupervisorChain returns the list of user IDs from the given user's supervisor upward (for cycle detection).
func (r *UserRepository) GetSupervisorChain(ctx context.Context, startUserID uuid.UUID) ([]uuid.UUID, error) {
	var chain []uuid.UUID
	currentID := startUserID
	for {
		var u model.User
		if err := r.DB().WithContext(ctx).Select("supervisor_id").Where("id = ?", currentID).First(&u).Error; err != nil {
			return nil, err
		}
		if u.SupervisorID == nil {
			break
		}
		chain = append(chain, *u.SupervisorID)
		currentID = *u.SupervisorID
	}
	return chain, nil
}

// Count returns total number of users.
func (r *UserRepository) Count(ctx context.Context) (int64, error) {
	var count int64
	err := r.DB().WithContext(ctx).Model(&model.User{}).Count(&count).Error
	return count, err
}

// GetRoleIDsForUser returns role IDs assigned to the user.
func (r *UserRepository) GetRoleIDsForUser(ctx context.Context, userID uuid.UUID) ([]uuid.UUID, error) {
	var ids []uuid.UUID
	err := r.DB().WithContext(ctx).Table("user_roles").
		Where("user_id = ?", userID).
		Pluck("role_id", &ids).Error
	return ids, err
}

// SetUserRoles replaces all role assignments for the user with the given role IDs (audit fields set in service).
func (r *UserRepository) SetUserRoles(ctx context.Context, userID uuid.UUID, roleIDs []uuid.UUID, createdBy uuid.UUID) error {
	return r.DB().WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		if err := tx.Where("user_id = ?", userID).Delete(&model.UserRole{}).Error; err != nil {
			return err
		}
		for _, roleID := range roleIDs {
			ur := model.UserRole{UserID: userID, RoleID: roleID}
			ur.CreatedBy = createdBy
			ur.UpdatedBy = createdBy
			if err := tx.Create(&ur).Error; err != nil {
				return err
			}
		}
		return nil
	})
}
