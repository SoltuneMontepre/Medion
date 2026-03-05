package service

import (
	"context"
	"errors"
	"net/http"
	"strings"
	"time"

	"backend/internal/constant"
	"backend/internal/converter"
	"backend/internal/dto"
	"backend/internal/model"
	"backend/internal/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ProductionPlanService struct {
	plans     *repository.ProductionPlanRepository
	items     *repository.ProductionPlanItemRepository
	products  *repository.ProductRepository
	users     *repository.UserRepository
	inventory *repository.InventoryRepository
	converter *converter.Converter
}

func NewProductionPlanService(
	plans *repository.ProductionPlanRepository,
	items *repository.ProductionPlanItemRepository,
	products *repository.ProductRepository,
	users *repository.UserRepository,
	inventory *repository.InventoryRepository,
	conv *converter.Converter,
) *ProductionPlanService {
	return &ProductionPlanService{
		plans:     plans,
		items:     items,
		products:  products,
		users:     users,
		inventory: inventory,
		converter: conv,
	}
}

func parsePlanDate(s string) (time.Time, bool) {
	if s == "" {
		return time.Time{}, false
	}
	t, err := time.Parse("2006-01-02", s)
	if err != nil {
		return time.Time{}, false
	}
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC), true
}

// GetByDate returns the production plan for the given date (YYYY-MM-DD). Returns nil payload and no error if not found.
func (s *ProductionPlanService) GetByDate(ctx context.Context, dateStr string) (*dto.ProductionPlanPayload, error) {
	planDate, ok := parsePlanDate(dateStr)
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2701, Message: constant.MsgProductionPlanDateRequired}
	}
	plan, err := s.plans.FindByPlanDateWithItems(ctx, planDate)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2702, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	payload := s.converter.ProductionPlanToPayload(*plan)
	return &payload, nil
}

// GetByID returns the production plan by id with items.
func (s *ProductionPlanService) GetByID(ctx context.Context, id uuid.UUID) (*dto.ProductionPlanPayload, error) {
	plan, err := s.plans.FindByIDWithItems(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2703, Message: constant.MsgProductionPlanNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2704, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	payload := s.converter.ProductionPlanToPayload(*plan)
	return &payload, nil
}

// Create creates a new production plan for the given date with items. One plan per day; returns error if plan already exists for date.
func (s *ProductionPlanService) Create(ctx context.Context, req *dto.CreateProductionPlanRequest, createdBy uuid.UUID) (*dto.ProductionPlanPayload, error) {
	planDate, ok := parsePlanDate(req.PlanDate)
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2705, Message: constant.MsgProductionPlanDateRequired}
	}
	if len(req.Items) == 0 {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2706, Message: constant.MsgProductionPlanItemsRequired}
	}
	exists, err := s.plans.ExistsByPlanDate(ctx, planDate)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2707, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	if exists {
		return nil, &dto.AppError{HTTPStatus: http.StatusConflict, Code: 2708, Message: constant.MsgProductionPlanAlreadyExistsForDate}
	}
	modelItems, err := s.buildPlanItems(ctx, req.Items)
	if err != nil {
		return nil, err
	}
	plan := model.ProductionPlan{
		PlanDate: planDate,
		Status:   model.ProductionPlanStatusDraft,
	}
	plan.CreatedBy = createdBy
	plan.UpdatedBy = createdBy
	if err := s.plans.DB().WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(&plan).Error; err != nil {
			return err
		}
		for i := range modelItems {
			modelItems[i].ProductionPlanID = plan.ID
			modelItems[i].CreatedBy = createdBy
			modelItems[i].UpdatedBy = createdBy
			if err := tx.Create(&modelItems[i]).Error; err != nil {
				return err
			}
		}
		return nil
	}); err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2709, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	loaded, _ := s.plans.FindByIDWithItems(ctx, plan.ID)
	payload := s.converter.ProductionPlanToPayload(*loaded)
	return &payload, nil
}

// Update updates an existing production plan (date and items). Plan must be draft or submitted.
// If plan is approved, only kế hoạch viên or trưởng phòng kế hoạch may edit; status reverts to submitted and requires re-approval.
func (s *ProductionPlanService) Update(ctx context.Context, id uuid.UUID, req *dto.UpdateProductionPlanRequest, updatedBy uuid.UUID) (*dto.ProductionPlanPayload, error) {
	planDate, ok := parsePlanDate(req.PlanDate)
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2710, Message: constant.MsgProductionPlanDateRequired}
	}
	if len(req.Items) == 0 {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2711, Message: constant.MsgProductionPlanItemsRequired}
	}
	plan, err := s.plans.FindByIDWithItems(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2712, Message: constant.MsgProductionPlanNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2713, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	if plan.Status == model.ProductionPlanStatusApproved {
		isPlanner, err := s.hasRole(ctx, updatedBy, constant.RoleCodeKeHoachVien)
		if err != nil {
			return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2713, Message: constant.MsgProductionPlanServerError, Err: err}
		}
		isHead, err := s.hasRole(ctx, updatedBy, constant.RoleCodeTruongPhongKeHoach)
		if err != nil {
			return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2713, Message: constant.MsgProductionPlanServerError, Err: err}
		}
		if !isPlanner && !isHead {
			return nil, &dto.AppError{HTTPStatus: http.StatusForbidden, Code: 2724, Message: constant.MsgProductionPlanForbidden}
		}
		// Revert inventory: subtract quantities that were added when plan was approved
		for _, item := range plan.Items {
			if item.PlannedQuantity > 0 {
				if err := s.inventory.SubtractQuantity(ctx, item.ProductID, int64(item.PlannedQuantity)); err != nil {
					return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2740, Message: constant.MsgProductionPlanServerError, Err: err}
				}
			}
		}
		plan.Status = model.ProductionPlanStatusSubmitted
		plan.ApprovedAt = nil
		plan.ApprovedBy = nil
	}
	modelItems, err := s.buildPlanItems(ctx, req.Items)
	if err != nil {
		return nil, err
	}
	plan.PlanDate = planDate
	plan.UpdatedBy = updatedBy
	if err := s.plans.DB().WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		if err := tx.Save(plan).Error; err != nil {
			return err
		}
		if err := tx.Where("production_plan_id = ?", id).Delete(&model.ProductionPlanItem{}).Error; err != nil {
			return err
		}
		for i := range modelItems {
			modelItems[i].ProductionPlanID = id
			modelItems[i].CreatedBy = updatedBy
			modelItems[i].UpdatedBy = updatedBy
			if err := tx.Create(&modelItems[i]).Error; err != nil {
				return err
			}
		}
		return nil
	}); err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2715, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	loaded, _ := s.plans.FindByIDWithItems(ctx, id)
	payload := s.converter.ProductionPlanToPayload(*loaded)
	return &payload, nil
}

func (s *ProductionPlanService) buildPlanItems(ctx context.Context, items []dto.ProductionPlanItemPayload) ([]model.ProductionPlanItem, error) {
	out := make([]model.ProductionPlanItem, 0, len(items))
	for _, it := range items {
		if it.PlannedQuantity < 1 {
			return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2716, Message: constant.MsgProductionPlanQuantityInvalid}
		}
		_, err := s.products.FindByID(ctx, it.ProductID)
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2717, Message: constant.MsgProductNotFound}
			}
			return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2718, Message: constant.MsgProductionPlanServerError, Err: err}
		}
		out = append(out, model.ProductionPlanItem{
			ProductID:       it.ProductID,
			Ordinal:         it.Ordinal,
			PlannedQuantity: it.PlannedQuantity,
		})
	}
	return out, nil
}

func (s *ProductionPlanService) hasRole(ctx context.Context, userID uuid.UUID, code string) (bool, error) {
	codes, err := s.users.GetRoleCodesForUser(ctx, userID)
	if err != nil {
		return false, err
	}
	return constant.HasRoleOrAdmin(codes, code), nil
}

// Submit moves a plan from draft to submitted. Only planning staff or head of planning can submit.
func (s *ProductionPlanService) Submit(ctx context.Context, id uuid.UUID, userID uuid.UUID) (*dto.ProductionPlanPayload, error) {
	isPlanner, err := s.hasRole(ctx, userID, constant.RoleCodeKeHoachVien)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2723, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	isHead, err := s.hasRole(ctx, userID, constant.RoleCodeTruongPhongKeHoach)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2723, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	if !isPlanner && !isHead {
		return nil, &dto.AppError{HTTPStatus: http.StatusForbidden, Code: 2724, Message: constant.MsgProductionPlanForbidden}
	}
	plan, err := s.plans.FindByIDWithItems(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2703, Message: constant.MsgProductionPlanNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2723, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	if plan.Status != model.ProductionPlanStatusDraft {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2725, Message: constant.MsgProductionPlanInvalidStatus}
	}
	plan.Status = model.ProductionPlanStatusSubmitted
	plan.UpdatedBy = userID
	if err := s.plans.DB().WithContext(ctx).Save(plan).Error; err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2723, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	loaded, _ := s.plans.FindByIDWithItems(ctx, id)
	payload := s.converter.ProductionPlanToPayload(*loaded)
	return &payload, nil
}

// Reject moves a plan from submitted back to draft. Only head of planning can reject.
func (s *ProductionPlanService) Reject(ctx context.Context, id uuid.UUID, rejectorID uuid.UUID, reason string) (*dto.ProductionPlanPayload, error) {
	isHead, err := s.hasRole(ctx, rejectorID, constant.RoleCodeTruongPhongKeHoach)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2728, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	if !isHead {
		return nil, &dto.AppError{HTTPStatus: http.StatusForbidden, Code: 2727, Message: constant.MsgProductionPlanForbidden}
	}
	plan, err := s.plans.FindByIDWithItems(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2703, Message: constant.MsgProductionPlanNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2728, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	if plan.Status != model.ProductionPlanStatusSubmitted {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2725, Message: constant.MsgProductionPlanInvalidStatus}
	}
	reasonTrimmed := strings.TrimSpace(reason)
	if reasonTrimmed == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2729, Message: constant.MsgProductionPlanRejectReasonRequired}
	}
	plan.Status = model.ProductionPlanStatusDraft
	plan.ApprovedAt = nil
	plan.ApprovedBy = nil
	plan.UpdatedBy = rejectorID
	if err := s.plans.DB().WithContext(ctx).Save(plan).Error; err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2728, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	loaded, _ := s.plans.FindByIDWithItems(ctx, id)
	payload := s.converter.ProductionPlanToPayload(*loaded)
	return &payload, nil
}

// Approve moves a plan from submitted to approved. Only head of planning can approve.
func (s *ProductionPlanService) Approve(ctx context.Context, id uuid.UUID, approverID uuid.UUID) (*dto.ProductionPlanPayload, error) {
	isHead, err := s.hasRole(ctx, approverID, constant.RoleCodeTruongPhongKeHoach)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2726, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	if !isHead {
		return nil, &dto.AppError{HTTPStatus: http.StatusForbidden, Code: 2727, Message: constant.MsgProductionPlanForbidden}
	}
	plan, err := s.plans.FindByIDWithItems(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2703, Message: constant.MsgProductionPlanNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2726, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	if plan.Status != model.ProductionPlanStatusSubmitted {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2725, Message: constant.MsgProductionPlanInvalidStatus}
	}
	now := time.Now().UTC()
	plan.Status = model.ProductionPlanStatusApproved
	plan.ApprovedAt = &now
	plan.ApprovedBy = &approverID
	plan.UpdatedBy = approverID
	if err := s.plans.DB().WithContext(ctx).Save(plan).Error; err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2726, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	// Add planned quantities to finished-product inventory when plan is approved
	for _, item := range plan.Items {
		if item.PlannedQuantity > 0 {
			if err := s.inventory.AddQuantity(ctx, item.ProductID, int64(item.PlannedQuantity)); err != nil {
				return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2740, Message: constant.MsgProductionPlanServerError, Err: err}
			}
		}
	}
	loaded, _ := s.plans.FindByIDWithItems(ctx, id)
	payload := s.converter.ProductionPlanToPayload(*loaded)
	return &payload, nil
}
