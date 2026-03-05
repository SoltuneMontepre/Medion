package repository

import (
	"context"

	"backend/internal/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type FinishedProductDispatchLineRepository struct {
	*Repository[model.FinishedProductDispatchLine]
	db *gorm.DB
}

func NewFinishedProductDispatchLineRepository(db *gorm.DB) *FinishedProductDispatchLineRepository {
	return &FinishedProductDispatchLineRepository{Repository: NewRepository[model.FinishedProductDispatchLine](db), db: db}
}

// DeleteByDispatchID removes all lines for a dispatch (for replace on update).
func (r *FinishedProductDispatchLineRepository) DeleteByDispatchID(ctx context.Context, dispatchID uuid.UUID) error {
	return r.DB().WithContext(ctx).Where("dispatch_id = ?", dispatchID).
		Delete(&model.FinishedProductDispatchLine{}).Error
}
