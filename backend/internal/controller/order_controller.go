package controller

import (
	"net/http"
	"strconv"

	"backend/internal/constant"
	"backend/internal/dto"
	"backend/internal/middleware"
	"backend/internal/service"

	"github.com/go-fuego/fuego"
	"github.com/google/uuid"
)

type OrderController struct {
	orderService *service.OrderService
}

func NewOrderController(orderService *service.OrderService) *OrderController {
	return &OrderController{orderService: orderService}
}

type listOrdersResponse struct {
	Items []dto.OrderPayload `json:"items"`
	Total int64              `json:"total"`
}

func (oc *OrderController) List(c fuego.ContextNoBody) (*dto.Envelope[listOrdersResponse], error) {
	token, ok := middleware.GetAccessTokenFromContext(c.Context())
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1011, Message: "access token is missing"}
	}
	page, _ := strconv.Atoi(c.QueryParam("page"))
	if page < 1 {
		page = 1
	}
	pageSize, _ := strconv.Atoi(c.QueryParam("pageSize"))
	if pageSize < 1 {
		pageSize = 20
	}
	items, total, err := oc.orderService.List(c.Context(), token, page, pageSize)
	if err != nil {
		return nil, err
	}
	return dto.Ok(listOrdersResponse{Items: items, Total: total}, "success", http.StatusOK), nil
}

func (oc *OrderController) GetByID(c fuego.ContextNoBody) (*dto.Envelope[dto.OrderDetailPayload], error) {
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2099, Message: "invalid order id"}
	}
	detail, err := oc.orderService.GetByID(c.Context(), id)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*detail, "success", http.StatusOK), nil
}

// CheckCustomerOrderToday: GET /sale/orders/check-today?customerId=...
func (oc *OrderController) CheckCustomerOrderToday(c fuego.ContextNoBody) (*dto.Envelope[dto.CheckCustomerOrderTodayResponse], error) {
	idStr := c.QueryParam("customerId")
	if idStr == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2098, Message: "customerId is required"}
	}
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2099, Message: "invalid customer id"}
	}
	resp, err := oc.orderService.CheckCustomerOrderToday(c.Context(), id)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*resp, "success", http.StatusOK), nil
}

func (oc *OrderController) Create(c fuego.ContextWithBody[dto.CreateOrderRequest]) (*dto.Envelope[dto.OrderDetailPayload], error) {
	token, ok := middleware.GetAccessTokenFromContext(c.Context())
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1011, Message: "access token is missing"}
	}
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	detail, err := oc.orderService.Create(c.Context(), body, token)
	if err != nil {
		return nil, err
	}
	c.SetStatus(http.StatusCreated)
	return dto.Ok(*detail, constant.MsgOrderSaveSuccess, http.StatusCreated), nil
}
