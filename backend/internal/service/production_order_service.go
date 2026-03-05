package service

import (
	"context"
	"errors"
	"fmt"
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

type ProductionOrderService struct {
	orders      *repository.ProductionOrderRepository
	products    *repository.ProductRepository
	ingredients *repository.IngredientRepository
	inventory   *repository.InventoryRepository
	converter   *converter.Converter
}

func NewProductionOrderService(
	orders *repository.ProductionOrderRepository,
	products *repository.ProductRepository,
	ingredients *repository.IngredientRepository,
	inventory *repository.InventoryRepository,
	conv *converter.Converter,
) *ProductionOrderService {
	return &ProductionOrderService{
		orders:      orders,
		products:    products,
		ingredients: ingredients,
		inventory:  inventory,
		converter:   conv,
	}
}

func parseOrderDate(s string) (time.Time, bool) {
	s = strings.TrimSpace(s)
	if s == "" {
		return time.Time{}, false
	}
	t, err := time.Parse("2006-01-02", s)
	if err != nil {
		return time.Time{}, false
	}
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC), true
}

// generateOrderNumber produces LSX + DDMMYYYY format (e.g. LSX15102025).
func generateOrderNumber(prodDate time.Time) string {
	d := prodDate.Day()
	m := int(prodDate.Month())
	y := prodDate.Year()
	return fmt.Sprintf("LSX%02d%02d%04d", d, m, y)
}

// List returns paginated production orders.
func (s *ProductionOrderService) List(ctx context.Context, status string, limit, offset int) (*dto.ProductionOrderListResponse, error) {
	if limit <= 0 {
		limit = 20
	}
	if offset < 0 {
		offset = 0
	}
	list, total, err := s.orders.List(ctx, limit, offset, status)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2731, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	items := make([]dto.ProductionOrderPayload, len(list))
	for i := range list {
		items[i] = s.converter.ProductionOrderToPayload(list[i])
	}
	return &dto.ProductionOrderListResponse{Items: items, Total: total, Limit: limit, Offset: offset}, nil
}

// GetByID returns a production order by id.
func (s *ProductionOrderService) GetByID(ctx context.Context, id uuid.UUID) (*dto.ProductionOrderPayload, error) {
	o, err := s.orders.FindByIDWithProduct(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2732, Message: constant.MsgProductionOrderNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2733, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	p := s.converter.ProductionOrderToPayload(*o)
	return &p, nil
}

// Create creates a new production order. Business rule: 1 order = 1 product (enforced by model).
func (s *ProductionOrderService) Create(ctx context.Context, req *dto.CreateProductionOrderRequest, createdBy uuid.UUID) (*dto.ProductionOrderPayload, error) {
	if req.ProductID == uuid.Nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2734, Message: constant.MsgProductionOrderProductRequired}
	}
	_, err := s.products.FindByID(ctx, req.ProductID)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2717, Message: constant.MsgProductNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2735, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	prodDate, ok := parseOrderDate(req.ProductionDate)
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2736, Message: constant.MsgProductionPlanDateRequired}
	}
	expDate, ok := parseOrderDate(req.ExpiryDate)
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2736, Message: constant.MsgProductionOrderExpiryRequired}
	}
	if req.BatchSizeLit <= 0 {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2737, Message: constant.MsgProductionOrderQuantityInvalid}
	}
	if req.QuantitySpec1 < 0 || req.QuantitySpec2 < 0 {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2737, Message: constant.MsgProductionOrderQuantityInvalid}
	}
	batchNumber := strings.TrimSpace(req.BatchNumber)
	if batchNumber == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2738, Message: constant.MsgProductionOrderBatchRequired}
	}
	orderNumber := generateOrderNumber(prodDate)
	exists, err := s.orders.ExistsByOrderNumber(ctx, orderNumber)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2735, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	if exists {
		orderNumber = fmt.Sprintf("%s-%s", orderNumber, uuid.New().String()[:8])
	}
	o := model.ProductionOrder{
		OrderNumber:         orderNumber,
		ProductID:           req.ProductID,
		BatchNumber:         batchNumber,
		ProductionDate:     prodDate,
		ExpiryDate:         expDate,
		BatchSizeLit:       req.BatchSizeLit,
		QuantitySpec1:      req.QuantitySpec1,
		QuantitySpec2:      req.QuantitySpec2,
		Status:             model.ProductionOrderStatusDraft,
		ProductionPlanItemID: req.PlanItemID,
	}
	o.CreatedBy = createdBy
	o.UpdatedBy = createdBy
	if err := s.orders.DB().WithContext(ctx).Create(&o).Error; err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2735, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	// Create ingredient lines
	for ord, in := range req.Ingredients {
		if in.IngredientID == uuid.Nil || in.Quantity <= 0 {
			continue
		}
		_, err := s.ingredients.FindByID(ctx, in.IngredientID)
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				continue // skip invalid ingredient
			}
			return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2735, Message: constant.MsgProductionPlanServerError, Err: err}
		}
		unit := strings.TrimSpace(in.Unit)
		if unit == "" {
			unit = "kg"
		}
		ing := model.ProductionOrderIngredient{
			ProductionOrderID:   o.ID,
			IngredientID:       in.IngredientID,
			Quantity:            in.Quantity,
			QuantityAdjustment: in.QuantityAdjustment,
			Unit:                unit,
			Notes:               strings.TrimSpace(in.Notes),
			Ordinal:             ord,
		}
		ing.CreatedBy = createdBy
		ing.UpdatedBy = createdBy
		if err := s.orders.DB().WithContext(ctx).Create(&ing).Error; err != nil {
			return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2735, Message: constant.MsgProductionPlanServerError, Err: err}
		}
	}
	loaded, _ := s.orders.FindByIDWithProduct(ctx, o.ID)
	p := s.converter.ProductionOrderToPayload(*loaded)
	return &p, nil
}

// Update updates a draft production order.
func (s *ProductionOrderService) Update(ctx context.Context, id uuid.UUID, req *dto.UpdateProductionOrderRequest, updatedBy uuid.UUID) (*dto.ProductionOrderPayload, error) {
	o, err := s.orders.FindByIDWithProduct(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2732, Message: constant.MsgProductionOrderNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2733, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	if o.Status != model.ProductionOrderStatusDraft {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2739, Message: constant.MsgProductionOrderDraftOnlyEdit}
	}
	prodDate, ok := parseOrderDate(req.ProductionDate)
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2736, Message: constant.MsgProductionPlanDateRequired}
	}
	expDate, ok := parseOrderDate(req.ExpiryDate)
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2736, Message: constant.MsgProductionOrderExpiryRequired}
	}
	if req.BatchSizeLit <= 0 {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2737, Message: constant.MsgProductionOrderQuantityInvalid}
	}
	batchNumber := strings.TrimSpace(req.BatchNumber)
	if batchNumber == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2738, Message: constant.MsgProductionOrderBatchRequired}
	}
	o.BatchNumber = batchNumber
	o.ProductionDate = prodDate
	o.ExpiryDate = expDate
	o.BatchSizeLit = req.BatchSizeLit
	o.QuantitySpec1 = req.QuantitySpec1
	o.QuantitySpec2 = req.QuantitySpec2
	o.UpdatedBy = updatedBy
	if err := s.orders.DB().WithContext(ctx).Save(o).Error; err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2735, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	// Replace ingredients
	if err := s.orders.DB().WithContext(ctx).Where("production_order_id = ?", id).Delete(&model.ProductionOrderIngredient{}).Error; err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2735, Message: constant.MsgProductionPlanServerError, Err: err}
	}
	for ord, in := range req.Ingredients {
		if in.IngredientID == uuid.Nil || in.Quantity <= 0 {
			continue
		}
		_, err := s.ingredients.FindByID(ctx, in.IngredientID)
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				continue
			}
			return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2735, Message: constant.MsgProductionPlanServerError, Err: err}
		}
		unit := strings.TrimSpace(in.Unit)
		if unit == "" {
			unit = "kg"
		}
		ing := model.ProductionOrderIngredient{
			ProductionOrderID:   id,
			IngredientID:       in.IngredientID,
			Quantity:           in.Quantity,
			QuantityAdjustment: in.QuantityAdjustment,
			Unit:               unit,
			Notes:              strings.TrimSpace(in.Notes),
			Ordinal:            ord,
		}
		ing.CreatedBy = updatedBy
		ing.UpdatedBy = updatedBy
		if err := s.orders.DB().WithContext(ctx).Create(&ing).Error; err != nil {
			return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2735, Message: constant.MsgProductionPlanServerError, Err: err}
		}
	}
	loaded, _ := s.orders.FindByIDWithProduct(ctx, id)
	p := s.converter.ProductionOrderToPayload(*loaded)
	return &p, nil
}
