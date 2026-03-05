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

type FinishedProductDispatchService struct {
	dispatches *repository.FinishedProductDispatchRepository
	lines      *repository.FinishedProductDispatchLineRepository
	customers  *repository.CustomerRepository
	products   *repository.ProductRepository
	inventory  *repository.InventoryRepository
	users      *repository.UserRepository
	converter  *converter.Converter
}

func NewFinishedProductDispatchService(
	dispatches *repository.FinishedProductDispatchRepository,
	lines *repository.FinishedProductDispatchLineRepository,
	customers *repository.CustomerRepository,
	products *repository.ProductRepository,
	inventory *repository.InventoryRepository,
	users *repository.UserRepository,
	conv *converter.Converter,
) *FinishedProductDispatchService {
	return &FinishedProductDispatchService{
		dispatches: dispatches,
		lines:      lines,
		customers:  customers,
		products:   products,
		inventory:  inventory,
		users:      users,
		converter:  conv,
	}
}

func (s *FinishedProductDispatchService) hasRole(ctx context.Context, userID uuid.UUID, code string) (bool, error) {
	codes, err := s.users.GetRoleCodesForUser(ctx, userID)
	if err != nil {
		return false, err
	}
	for _, c := range codes {
		if c == code {
			return true, nil
		}
	}
	return false, nil
}

func parseDate(s string) (*time.Time, bool) {
	s = strings.TrimSpace(s)
	if s == "" {
		return nil, true
	}
	t, err := time.Parse("2006-01-02", s)
	if err != nil {
		return nil, false
	}
	utc := time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC)
	return &utc, true
}

// GetByID returns a dispatch by id with items.
func (s *FinishedProductDispatchService) GetByID(ctx context.Context, id uuid.UUID) (*dto.FinishedProductDispatchPayload, error) {
	d, err := s.dispatches.FindByIDWithItems(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2801, Message: constant.MsgDispatchNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2802, Message: constant.MsgDispatchServerError, Err: err}
	}
	payload := s.converter.FinishedProductDispatchToPayload(*d)
	return &payload, nil
}

// List returns paginated dispatches with optional status filter.
func (s *FinishedProductDispatchService) List(ctx context.Context, status string, limit, offset int) (*dto.FinishedProductDispatchListResponse, error) {
	if limit <= 0 {
		limit = 20
	}
	if offset < 0 {
		offset = 0
	}
	list, err := s.dispatches.List(ctx, status, limit, offset)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2803, Message: constant.MsgDispatchServerError, Err: err}
	}
	total, err := s.dispatches.Count(ctx, status)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2804, Message: constant.MsgDispatchServerError, Err: err}
	}
	items := make([]dto.FinishedProductDispatchPayload, len(list))
	for i := range list {
		items[i] = s.converter.FinishedProductDispatchToPayload(list[i])
	}
	return &dto.FinishedProductDispatchListResponse{Items: items, Total: total, Limit: limit, Offset: offset}, nil
}

// Create creates a new dispatch (draft). Kế toán kho.
func (s *FinishedProductDispatchService) Create(ctx context.Context, req *dto.CreateFinishedProductDispatchRequest, createdBy uuid.UUID) (*dto.FinishedProductDispatchPayload, error) {
	if req.CustomerID == uuid.Nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2805, Message: constant.MsgDispatchCustomerRequired}
	}
	orderNumber := strings.TrimSpace(req.OrderNumber)
	if orderNumber == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2806, Message: constant.MsgDispatchOrderNumberRequired}
	}
	address := strings.TrimSpace(req.Address)
	if address == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2807, Message: constant.MsgDispatchAddressRequired}
	}
	phone := strings.TrimSpace(req.Phone)
	if phone == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2808, Message: constant.MsgDispatchPhoneRequired}
	}
	if len(req.Items) == 0 {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2809, Message: constant.MsgDispatchItemsRequired}
	}
	_, err := s.customers.FindByID(ctx, req.CustomerID)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2810, Message: constant.MsgDispatchCustomerNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2811, Message: constant.MsgDispatchServerError, Err: err}
	}
	modelLines, err := s.buildDispatchLines(ctx, req.Items)
	if err != nil {
		return nil, err
	}
	d := model.FinishedProductDispatch{
		CustomerID:  req.CustomerID,
		OrderNumber:  orderNumber,
		Address:     address,
		Phone:       phone,
		Status:      model.FinishedProductDispatchStatusDraft,
	}
	d.CreatedBy = createdBy
	d.UpdatedBy = createdBy
	if err := s.dispatches.DB().WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(&d).Error; err != nil {
			return err
		}
		for i := range modelLines {
			modelLines[i].DispatchID = d.ID
			modelLines[i].CreatedBy = createdBy
			modelLines[i].UpdatedBy = createdBy
			if err := tx.Create(&modelLines[i]).Error; err != nil {
				return err
			}
		}
		return nil
	}); err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2812, Message: constant.MsgDispatchServerError, Err: err}
	}
	loaded, _ := s.dispatches.FindByIDWithItems(ctx, d.ID)
	payload := s.converter.FinishedProductDispatchToPayload(*loaded)
	return &payload, nil
}

// Update updates a dispatch (only draft or revision_requested).
func (s *FinishedProductDispatchService) Update(ctx context.Context, id uuid.UUID, req *dto.UpdateFinishedProductDispatchRequest, updatedBy uuid.UUID) (*dto.FinishedProductDispatchPayload, error) {
	orderNumber := strings.TrimSpace(req.OrderNumber)
	if orderNumber == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2806, Message: constant.MsgDispatchOrderNumberRequired}
	}
	address := strings.TrimSpace(req.Address)
	if address == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2807, Message: constant.MsgDispatchAddressRequired}
	}
	phone := strings.TrimSpace(req.Phone)
	if phone == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2808, Message: constant.MsgDispatchPhoneRequired}
	}
	if len(req.Items) == 0 {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2809, Message: constant.MsgDispatchItemsRequired}
	}
	d, err := s.dispatches.FindByIDWithItems(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2801, Message: constant.MsgDispatchNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2813, Message: constant.MsgDispatchServerError, Err: err}
	}
	if d.Status != model.FinishedProductDispatchStatusDraft && d.Status != model.FinishedProductDispatchStatusRevisionRequested {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2814, Message: constant.MsgDispatchInvalidStatus}
	}
	modelLines, err := s.buildDispatchLines(ctx, req.Items)
	if err != nil {
		return nil, err
	}
	d.OrderNumber = orderNumber
	d.Address = address
	d.Phone = phone
	d.RejectionReason = ""
	d.UpdatedBy = updatedBy
	if err := s.dispatches.DB().WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		if err := tx.Save(d).Error; err != nil {
			return err
		}
		if err := tx.Where("dispatch_id = ?", id).Delete(&model.FinishedProductDispatchLine{}).Error; err != nil {
			return err
		}
		for i := range modelLines {
			modelLines[i].DispatchID = id
			modelLines[i].CreatedBy = updatedBy
			modelLines[i].UpdatedBy = updatedBy
			if err := tx.Create(&modelLines[i]).Error; err != nil {
				return err
			}
		}
		return nil
	}); err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2815, Message: constant.MsgDispatchServerError, Err: err}
	}
	loaded, _ := s.dispatches.FindByIDWithItems(ctx, id)
	payload := s.converter.FinishedProductDispatchToPayload(*loaded)
	return &payload, nil
}

func (s *FinishedProductDispatchService) buildDispatchLines(ctx context.Context, items []dto.FinishedProductDispatchLinePayload) ([]model.FinishedProductDispatchLine, error) {
	out := make([]model.FinishedProductDispatchLine, 0, len(items))
	for _, it := range items {
		if it.Quantity < 1 {
			return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2816, Message: constant.MsgDispatchQuantityInvalid}
		}
		_, err := s.products.FindByID(ctx, it.ProductID)
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2817, Message: constant.MsgDispatchProductNotFound}
			}
			return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2818, Message: constant.MsgDispatchServerError, Err: err}
		}
		var mfg, exp *time.Time
		if it.ManufacturingDate != "" {
			t, ok := parseDate(it.ManufacturingDate)
			if !ok {
				return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2819, Message: "ngày sản xuất không hợp lệ (YYYY-MM-DD)"}
			}
			if t != nil {
				mfg = t
			}
		}
		if it.ExpiryDate != "" {
			t, ok := parseDate(it.ExpiryDate)
			if !ok {
				return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2820, Message: "ngày hết hạn không hợp lệ (YYYY-MM-DD)"}
			}
			if t != nil {
				exp = t
			}
		}
		out = append(out, model.FinishedProductDispatchLine{
			ProductID:         it.ProductID,
			Ordinal:            it.Ordinal,
			Quantity:          it.Quantity,
			LotNumber:         strings.TrimSpace(it.LotNumber),
			ManufacturingDate:  mfg,
			ExpiryDate:         exp,
		})
	}
	return out, nil
}

// checkInventorySufficient verifies finished-product inventory >= quantities in lines.
func (s *FinishedProductDispatchService) checkInventorySufficient(ctx context.Context, lines []model.FinishedProductDispatchLine) error {
	for _, line := range lines {
		inv, err := s.inventory.FindByProductIDAndWarehouseType(ctx, line.ProductID, model.WarehouseTypeFinished)
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2821, Message: constant.MsgDispatchInsufficientStock}
			}
			return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2822, Message: constant.MsgDispatchServerError, Err: err}
		}
		if inv.Quantity < int64(line.Quantity) {
			return &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2821, Message: constant.MsgDispatchInsufficientStock}
		}
	}
	return nil
}

// Submit moves draft or revision_requested to pending_approval (Báo cho Quản lý kho). Kế toán kho.
func (s *FinishedProductDispatchService) Submit(ctx context.Context, id uuid.UUID, userID uuid.UUID) (*dto.FinishedProductDispatchPayload, error) {
	isAccountant, err := s.hasRole(ctx, userID, constant.RoleCodeKeToanKho)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2823, Message: constant.MsgDispatchServerError, Err: err}
	}
	if !isAccountant {
		return nil, &dto.AppError{HTTPStatus: http.StatusForbidden, Code: 2824, Message: constant.MsgDispatchForbidden}
	}
	d, err := s.dispatches.FindByIDWithItems(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2801, Message: constant.MsgDispatchNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2823, Message: constant.MsgDispatchServerError, Err: err}
	}
	if d.Status != model.FinishedProductDispatchStatusDraft && d.Status != model.FinishedProductDispatchStatusRevisionRequested {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2814, Message: constant.MsgDispatchInvalidStatus}
	}
	if err := s.checkInventorySufficient(ctx, d.Items); err != nil {
		return nil, err
	}
	d.Status = model.FinishedProductDispatchStatusPendingApproval
	d.RejectionReason = ""
	d.UpdatedBy = userID
	if err := s.dispatches.DB().WithContext(ctx).Save(d).Error; err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2823, Message: constant.MsgDispatchServerError, Err: err}
	}
	loaded, _ := s.dispatches.FindByIDWithItems(ctx, id)
	payload := s.converter.FinishedProductDispatchToPayload(*loaded)
	return &payload, nil
}

// Approve moves pending_approval to approved. Quản lý kho.
func (s *FinishedProductDispatchService) Approve(ctx context.Context, id uuid.UUID, approverID uuid.UUID) (*dto.FinishedProductDispatchPayload, error) {
	isManager, err := s.hasRole(ctx, approverID, constant.RoleCodeQuanLyKho)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2825, Message: constant.MsgDispatchServerError, Err: err}
	}
	if !isManager {
		return nil, &dto.AppError{HTTPStatus: http.StatusForbidden, Code: 2824, Message: constant.MsgDispatchForbidden}
	}
	d, err := s.dispatches.FindByIDWithItems(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2801, Message: constant.MsgDispatchNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2825, Message: constant.MsgDispatchServerError, Err: err}
	}
	if d.Status != model.FinishedProductDispatchStatusPendingApproval {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2814, Message: constant.MsgDispatchInvalidStatus}
	}
	now := time.Now().UTC()
	d.Status = model.FinishedProductDispatchStatusApproved
	d.ApprovedAt = &now
	d.ApprovedBy = &approverID
	d.RejectionReason = ""
	d.UpdatedBy = approverID
	if err := s.dispatches.DB().WithContext(ctx).Save(d).Error; err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2825, Message: constant.MsgDispatchServerError, Err: err}
	}
	loaded, _ := s.dispatches.FindByIDWithItems(ctx, id)
	payload := s.converter.FinishedProductDispatchToPayload(*loaded)
	return &payload, nil
}

// Reject moves pending_approval to revision_requested (yêu cầu sửa). Quản lý kho.
func (s *FinishedProductDispatchService) Reject(ctx context.Context, id uuid.UUID, approverID uuid.UUID, reason string) (*dto.FinishedProductDispatchPayload, error) {
	isManager, err := s.hasRole(ctx, approverID, constant.RoleCodeQuanLyKho)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2826, Message: constant.MsgDispatchServerError, Err: err}
	}
	if !isManager {
		return nil, &dto.AppError{HTTPStatus: http.StatusForbidden, Code: 2824, Message: constant.MsgDispatchForbidden}
	}
	reason = strings.TrimSpace(reason)
	if reason == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2827, Message: constant.MsgDispatchRejectReasonRequired}
	}
	d, err := s.dispatches.FindByIDWithItems(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2801, Message: constant.MsgDispatchNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2826, Message: constant.MsgDispatchServerError, Err: err}
	}
	if d.Status != model.FinishedProductDispatchStatusPendingApproval {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2814, Message: constant.MsgDispatchInvalidStatus}
	}
	d.Status = model.FinishedProductDispatchStatusRevisionRequested
	d.RejectionReason = reason
	d.UpdatedBy = approverID
	if err := s.dispatches.DB().WithContext(ctx).Save(d).Error; err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2826, Message: constant.MsgDispatchServerError, Err: err}
	}
	loaded, _ := s.dispatches.FindByIDWithItems(ctx, id)
	payload := s.converter.FinishedProductDispatchToPayload(*loaded)
	return &payload, nil
}
