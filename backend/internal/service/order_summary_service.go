package service

import (
	"context"
	"errors"
	"net/http"
	"time"

	"backend/internal/constant"
	"backend/internal/converter"
	"backend/internal/dto"
	"backend/internal/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type OrderSummaryService struct {
	summaries *repository.OrderSummaryRepository
	items     *repository.OrderSummaryItemRepository
	users     *repository.UserRepository
	converter *converter.Converter
}

func NewOrderSummaryService(
	summaries *repository.OrderSummaryRepository,
	items *repository.OrderSummaryItemRepository,
	users *repository.UserRepository,
	conv *converter.Converter,
) *OrderSummaryService {
	return &OrderSummaryService{
		summaries: summaries,
		items:     items,
		users:     users,
		converter: conv,
	}
}

// parseSummaryDate parses YYYY-MM-DD to UTC date. Returns zero time and false on parse error.
func parseSummaryDate(s string) (time.Time, bool) {
	if s == "" {
		return time.Time{}, false
	}
	t, err := time.Parse("2006-01-02", s)
	if err != nil {
		return time.Time{}, false
	}
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC), true
}

// List returns order summaries for the current user. Only users with role sale_admin see the global summary (owner_id = Nil). Read-only.
func (s *OrderSummaryService) List(ctx context.Context, userID uuid.UUID, page, pageSize int) ([]dto.OrderSummaryPayload, int64, error) {
	roleCodes, err := s.users.GetRoleCodesForUser(ctx, userID)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2601, Message: constant.MsgOrderSummaryServerError, Err: err}
	}
	if !orderSummaryHasAccess(roleCodes) {
		return []dto.OrderSummaryPayload{}, 0, nil
	}
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	offset := (page - 1) * pageSize
	// Global summary: owner_id = Nil (all sale_person orders aggregated here)
	list, err := s.summaries.FindAllByOwnerID(ctx, uuid.Nil, pageSize, offset)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2601, Message: constant.MsgOrderSummaryServerError, Err: err}
	}
	total, err := s.summaries.CountByOwnerID(ctx, uuid.Nil)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2602, Message: constant.MsgOrderSummaryServerError, Err: err}
	}
	payloads := make([]dto.OrderSummaryPayload, len(list))
	for i, os := range list {
		itemCount, _ := s.items.CountByOrderSummaryID(ctx, os.ID)
		payloads[i] = s.converter.OrderSummaryToPayload(os, int(itemCount))
	}
	return payloads, total, nil
}

func orderSummaryHasAccess(roleCodes []string) bool {
	for _, c := range roleCodes {
		if c == constant.RoleCodeSaleAdmin {
			return true
		}
	}
	return false
}

// GetByID returns one summary by id; only sale_admin can view (global summary has OwnerID = Nil).
func (s *OrderSummaryService) GetByID(ctx context.Context, id uuid.UUID, userID uuid.UUID) (*dto.OrderSummaryDetailPayload, error) {
	roleCodes, err := s.users.GetRoleCodesForUser(ctx, userID)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2604, Message: constant.MsgOrderSummaryServerError, Err: err}
	}
	if !orderSummaryHasAccess(roleCodes) {
		return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2603, Message: constant.MsgOrderSummaryNotFound}
	}
	os, err := s.summaries.FindByIDWithItems(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2603, Message: constant.MsgOrderSummaryNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2604, Message: constant.MsgOrderSummaryServerError, Err: err}
	}
	if os.OwnerID != uuid.Nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2603, Message: constant.MsgOrderSummaryNotFound}
	}
	itemDetails := make([]dto.OrderSummaryItemDetail, len(os.Items))
	for i, osi := range os.Items {
		itemDetails[i] = s.converter.OrderSummaryItemToDetail(osi)
	}
	detail := s.converter.OrderSummaryToDetailPayload(*os, itemDetails)
	return &detail, nil
}

// GetByDate returns the global summary for the given date. Only sale_admin can view. Read-only.
func (s *OrderSummaryService) GetByDate(ctx context.Context, dateStr string, userID uuid.UUID) (*dto.OrderSummaryDetailPayload, error) {
	roleCodes, err := s.users.GetRoleCodesForUser(ctx, userID)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2605, Message: constant.MsgOrderSummaryServerError, Err: err}
	}
	if !orderSummaryHasAccess(roleCodes) {
		return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2603, Message: constant.MsgOrderSummaryNotFound}
	}
	summaryDate, ok := parseSummaryDate(dateStr)
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2615, Message: constant.MsgOrderSummaryDateRequired}
	}
	os, err := s.summaries.FindBySummaryDateAndOwner(ctx, summaryDate, uuid.Nil)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2603, Message: constant.MsgOrderSummaryNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2605, Message: constant.MsgOrderSummaryServerError, Err: err}
	}
	items, err := s.items.FindByOrderSummaryID(ctx, os.ID)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2606, Message: constant.MsgOrderSummaryServerError, Err: err}
	}
	itemDetails := make([]dto.OrderSummaryItemDetail, len(items))
	for i, osi := range items {
		itemDetails[i] = s.converter.OrderSummaryItemToDetail(osi)
	}
	detail := s.converter.OrderSummaryToDetailPayload(*os, itemDetails)
	return &detail, nil
}
