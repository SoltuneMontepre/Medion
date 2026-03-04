package service

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"time"

	"backend/internal/constant"
	"backend/internal/converter"
	"backend/internal/dto"
	"backend/internal/model"
	"backend/internal/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type OrderService struct {
	orders     *repository.OrderRepository
	orderItems *repository.OrderItemRepository
	customers  *repository.CustomerRepository
	products   *repository.ProductRepository
	converter  *converter.Converter
}

func NewOrderService(
	orders *repository.OrderRepository,
	orderItems *repository.OrderItemRepository,
	customers *repository.CustomerRepository,
	products *repository.ProductRepository,
	conv *converter.Converter,
) *OrderService {
	return &OrderService{
		orders:     orders,
		orderItems: orderItems,
		customers:  customers,
		products:   products,
		converter:  conv,
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

// Create creates an order with items and signs it (PIN verification stub).
func (s *OrderService) Create(ctx context.Context, req dto.CreateOrderRequest) (*dto.OrderDetailPayload, error) {
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

	// PIN verification (stub: accept any non-empty PIN for now; can integrate real HSM later)
	if req.PIN == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2107, Message: constant.MsgOrderSignFailed}
	}

	now := time.Now()
	order := model.Order{
		CustomerID:  req.CustomerID,
		OrderNumber: check.NextOrderNumber,
		OrderDate:   now,
		Status:      model.OrderStatusSigned,
	}
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

	// Load items with product for response
	loadedItems, err := s.orderItems.FindByOrderID(ctx, order.ID)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2507, Message: constant.MsgOrderServerError, Err: err}
	}
	itemDetails := make([]dto.OrderItemDetail, len(loadedItems))
	for i, oi := range loadedItems {
		itemDetails[i] = s.converter.OrderItemToDetail(oi)
	}
	payload := s.converter.OrderToDetailPayload(order, customer.Code, customer.Name, itemDetails)
	return &payload, nil
}

// List returns paginated orders.
func (s *OrderService) List(ctx context.Context, page, pageSize int) ([]dto.OrderPayload, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	offset := (page - 1) * pageSize
	list, err := s.orders.FindAll(ctx, pageSize, offset)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2508, Message: constant.MsgOrderServerError, Err: err}
	}
	total, err := s.orders.Count(ctx)
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
