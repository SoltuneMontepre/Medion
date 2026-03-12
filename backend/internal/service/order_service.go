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

func containsRole(codes []string, role string) bool {
	for _, c := range codes {
		if c == role {
			return true
		}
	}
	return false
}

type OrderService struct {
	orders       *repository.OrderRepository
	orderItems   *repository.OrderItemRepository
	customers    *repository.CustomerRepository
	products     *repository.ProductRepository
	users        *repository.UserRepository
	summaries    *repository.OrderSummaryRepository
	summaryItems *repository.OrderSummaryItemRepository
	pins         *PINService
	converter    *converter.Converter
}

func NewOrderService(
	orders *repository.OrderRepository,
	orderItems *repository.OrderItemRepository,
	customers *repository.CustomerRepository,
	products *repository.ProductRepository,
	users *repository.UserRepository,
	summaries *repository.OrderSummaryRepository,
	summaryItems *repository.OrderSummaryItemRepository,
	pins *PINService,
	conv *converter.Converter,
) *OrderService {
	return &OrderService{
		orders:       orders,
		orderItems:   orderItems,
		customers:   customers,
		products:     products,
		users:        users,
		summaries:    summaries,
		summaryItems: summaryItems,
		pins:         pins,
		converter:    conv,
	}
}

// CheckCustomerOrderToday returns whether customer has an order today, existing order id if any, and next order number if not.
func (s *OrderService) CheckCustomerOrderToday(ctx context.Context, customerID uuid.UUID) (*dto.CheckCustomerOrderTodayResponse, error) {
	now := time.Now()
	count, err := s.orders.CountByCustomerAndDate(ctx, customerID, now)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2501, Message: constant.MsgOrderServerError, Err: err}
	}
	resp := &dto.CheckCustomerOrderTodayResponse{}
	if count > 0 {
		resp.HasOrderToday = true
		existing, err := s.orders.FindByCustomerAndDate(ctx, customerID, now)
		if err != nil {
			return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2502, Message: constant.MsgOrderServerError, Err: err}
		}
		resp.ExistingOrderID = existing.ID
		return resp, nil
	}
	prefix := "DH" + now.Format("20060102") + "-"
	n, err := s.orders.CountByDatePrefix(ctx, prefix)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2503, Message: constant.MsgOrderServerError, Err: err}
	}
	resp.NextOrderNumber = fmt.Sprintf("%s%03d", prefix, n+1)
	return resp, nil
}

// Create creates an order with items and verifies the user's PIN for digital signing.
func (s *OrderService) Create(ctx context.Context, req dto.CreateOrderRequest, accessToken string) (*dto.OrderDetailPayload, error) {
	// Validate customer
	if req.CustomerID == uuid.Nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2101, Message: constant.MsgOrderInvalidCustomer}
	}
	customer, err := s.customers.FindByID(ctx, req.CustomerID)
	if err != nil || customer == nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2102, Message: constant.MsgCustomerNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2504, Message: constant.MsgOrderServerError, Err: err}
	}

	// Check customer already has order today
	check, err := s.CheckCustomerOrderToday(ctx, req.CustomerID)
	if err != nil {
		return nil, err
	}
	if check.HasOrderToday {
		return nil, &dto.AppError{HTTPStatus: http.StatusConflict, Code: 2103, Message: constant.MsgOrderCustomerHasOrderToday}
	}

	// Validate items
	if len(req.Items) == 0 {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2104, Message: constant.MsgOrderProductRequired}
	}
	for _, it := range req.Items {
		if it.Quantity <= 0 {
			return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2105, Message: constant.MsgOrderQuantityInvalid}
		}
		if it.ProductID == uuid.Nil {
			return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2106, Message: constant.MsgOrderProductRequired}
		}
		_, err := s.products.FindByID(ctx, it.ProductID)
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2108, Message: constant.MsgProductNotFound}
			}
			return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2512, Message: constant.MsgOrderServerError, Err: err}
		}
	}

	// Verify PIN for digital signing (GMP: every order must be signed by an authenticated user).
	pinResult, err := s.pins.VerifyByToken(ctx, accessToken, req.PIN)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 2107, Message: constant.MsgOrderSignFailed, Err: err}
	}
	if !pinResult.Valid {
		return nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 2109, Message: constant.MsgOrderSignFailed}
	}

	creatorID, err := s.pins.UserIDFromToken(accessToken)
	if err != nil {
		return nil, err
	}

	now := time.Now()
	order := model.Order{
		CustomerID:  req.CustomerID,
		OrderNumber: check.NextOrderNumber,
		OrderDate:   now,
		Status:      model.OrderStatusSigned,
	}
	order.CreatedBy = creatorID
	order.UpdatedBy = creatorID
	if err := s.orders.Create(ctx, &order); err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2505, Message: constant.MsgOrderServerError, Err: err}
	}

	items := make([]model.OrderItem, len(req.Items))
	for i, it := range req.Items {
		items[i] = model.OrderItem{
			ProductID: it.ProductID,
			Quantity:  it.Quantity,
		}
	}
	if err := s.orderItems.CreateBatch(ctx, order.ID, items); err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2506, Message: constant.MsgOrderServerError, Err: err}
	}

	// Aggregate into the creator's order summary (per-owner daily summary; sale admin sees self + subordinates).
	summary, err := s.summaries.FindOrCreateByDateAndOwner(ctx, order.OrderDate, creatorID)
	if err != nil {
		// Log but do not fail the order; summary can be fixed later
		_ = err
	} else {
		for _, it := range items {
			_ = s.summaryItems.AddQuantity(ctx, summary.ID, it.ProductID, it.Quantity)
		}
	}

	// Load items with product for response (fallback: build from created items if FindByOrderID fails so we never return 500 after a successful create)
	var itemDetails []dto.OrderItemDetail
	loadedItems, err := s.orderItems.FindByOrderID(ctx, order.ID)
	if err != nil {
		// Order and items are already persisted; build response from in-memory items + product lookups
		itemDetails = make([]dto.OrderItemDetail, 0, len(items))
		for _, it := range items {
			prod, pErr := s.products.FindByID(ctx, it.ProductID)
			if pErr != nil || prod == nil {
				itemDetails = append(itemDetails, dto.OrderItemDetail{ProductID: it.ProductID, Quantity: it.Quantity})
				continue
			}
			itemDetails = append(itemDetails, s.converter.OrderItemToDetail(model.OrderItem{ProductID: it.ProductID, Quantity: it.Quantity, Product: prod}))
		}
	} else {
		itemDetails = make([]dto.OrderItemDetail, len(loadedItems))
		for i, oi := range loadedItems {
			itemDetails[i] = s.converter.OrderItemToDetail(oi)
		}
	}
	payload := s.converter.OrderToDetailPayload(order, customer.Code, customer.Name, itemDetails)
	return &payload, nil
}

// List returns paginated orders scoped by current user, with optional search, date, status filters and sort.
// accessToken is used to resolve the current user ID.
func (s *OrderService) List(ctx context.Context, accessToken string, page, pageSize int, query dto.ListOrdersQuery) ([]dto.OrderPayload, int64, error) {
	userID, err := s.pins.UserIDFromToken(accessToken)
	if err != nil {
		return nil, 0, err
	}
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	offset := (page - 1) * pageSize

	roleCodes, err := s.users.GetRoleCodesForUser(ctx, userID)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2508, Message: constant.MsgOrderServerError, Err: err}
	}

	filter := repository.ListOrdersFilter{
		Search:        strings.TrimSpace(query.Search),
		OrderDateFrom: query.StartDate,
		OrderDateTo:   query.EndDate,
		Status:        strings.TrimSpace(query.Status),
		SortBy:        query.SortBy,
		SortOrder:     query.SortOrder,
	}
	if filter.SortBy == "" {
		filter.SortBy = "created_at"
	}
	if filter.SortOrder == "" {
		filter.SortOrder = "desc"
	}

	var creatorIDs []uuid.UUID
	if constant.HasAdminRole(roleCodes) {
		creatorIDs = nil // all orders
	} else if containsRole(roleCodes, constant.RoleCodeSaleAdmin) {
		salePersonIDs, err := s.users.FindUserIDsByRoleCode(ctx, constant.RoleCodeSalePerson)
		if err != nil {
			return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2508, Message: constant.MsgOrderServerError, Err: err}
		}
		creatorIDs = make([]uuid.UUID, 0, len(salePersonIDs)+1)
		creatorIDs = append(creatorIDs, userID)
		creatorIDs = append(creatorIDs, salePersonIDs...)
	} else {
		creatorIDs = []uuid.UUID{userID}
	}

	list, err := s.orders.FindWithFilters(ctx, filter, creatorIDs, pageSize, offset)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2508, Message: constant.MsgOrderServerError, Err: err}
	}
	total, err := s.orders.CountWithFilters(ctx, filter, creatorIDs)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2509, Message: constant.MsgOrderServerError, Err: err}
	}

	payloads := make([]dto.OrderPayload, len(list))
	for i, o := range list {
		code, name := "", ""
		if o.Customer != nil {
			code, name = o.Customer.Code, o.Customer.Name
		}
		payloads[i] = s.converter.OrderToPayload(o, code, name)
	}
	return payloads, total, nil
}

// GetByID returns order detail by id.
func (s *OrderService) GetByID(ctx context.Context, id uuid.UUID) (*dto.OrderDetailPayload, error) {
	o, err := s.orders.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2110, Message: constant.MsgOrderNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2510, Message: constant.MsgOrderServerError, Err: err}
	}
	code, name := "", ""
	if o.Customer != nil {
		code, name = o.Customer.Code, o.Customer.Name
	}
	// Load customer if not preloaded
	if o.Customer == nil {
		customer, _ := s.customers.FindByID(ctx, o.CustomerID)
		if customer != nil {
			code, name = customer.Code, customer.Name
		}
	}
	items, err := s.orderItems.FindByOrderID(ctx, o.ID)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2511, Message: constant.MsgOrderServerError, Err: err}
	}
	itemDetails := make([]dto.OrderItemDetail, len(items))
	for i, oi := range items {
		itemDetails[i] = s.converter.OrderItemToDetail(oi)
	}
	detail := s.converter.OrderToDetailPayload(*o, code, name, itemDetails)
	return &detail, nil
}
