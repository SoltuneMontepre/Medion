package controller

import (
	"context"
	"net/http"
	"strconv"

	"backend/internal/constant"
	"backend/internal/dto"
	"backend/internal/middleware"
	"backend/internal/security"
	"backend/internal/service"

	"github.com/go-fuego/fuego"
	"github.com/google/uuid"
)

type OrderSummaryController struct {
	orderSummaryService *service.OrderSummaryService
	jwtManager          *security.JWTManager
}

func NewOrderSummaryController(orderSummaryService *service.OrderSummaryService, jwtManager *security.JWTManager) *OrderSummaryController {
	return &OrderSummaryController{
		orderSummaryService: orderSummaryService,
		jwtManager:          jwtManager,
	}
}

func (osc *OrderSummaryController) userIDFromContext(ctx context.Context) (uuid.UUID, error) {
	token, ok := middleware.GetAccessTokenFromContext(ctx)
	if !ok {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1011, Message: "access token is missing"}
	}
	claims, err := osc.jwtManager.ParseAccessToken(token)
	if err != nil {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1012, Message: "invalid or expired access token", Err: err}
	}
	id, err := uuid.Parse(claims.Subject)
	if err != nil {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1013, Message: "invalid user id in token", Err: err}
	}
	return id, nil
}

type listOrderSummariesResponse struct {
	Items []dto.OrderSummaryPayload `json:"items"`
	Total int64                      `json:"total"`
}

// List returns order summaries for the current user (sale admin). Read-only.
func (osc *OrderSummaryController) List(c fuego.ContextNoBody) (*dto.Envelope[listOrderSummariesResponse], error) {
	ownerID, err := osc.userIDFromContext(c.Context())
	if err != nil {
		return nil, err
	}
	page, _ := strconv.Atoi(c.QueryParam("page"))
	if page < 1 {
		page = 1
	}
	pageSize, _ := strconv.Atoi(c.QueryParam("pageSize"))
	if pageSize < 1 {
		pageSize = 20
	}
	items, total, err := osc.orderSummaryService.List(c.Context(), ownerID, page, pageSize)
	if err != nil {
		return nil, err
	}
	return dto.Ok(listOrderSummariesResponse{Items: items, Total: total}, "success", http.StatusOK), nil
}

// GetByDate returns the order summary for the given date (e.g. today) for the current sale admin. Read-only.
func (osc *OrderSummaryController) GetByDate(c fuego.ContextNoBody) (*dto.Envelope[dto.OrderSummaryDetailPayload], error) {
	ownerID, err := osc.userIDFromContext(c.Context())
	if err != nil {
		return nil, err
	}
	dateStr := c.QueryParam("date")
	if dateStr == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2698, Message: constant.MsgOrderSummaryDateRequired}
	}
	detail, err := osc.orderSummaryService.GetByDate(c.Context(), dateStr, ownerID)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*detail, "success", http.StatusOK), nil
}

// GetByID returns one order summary by id; only if it belongs to the current user (sale admin). Read-only.
func (osc *OrderSummaryController) GetByID(c fuego.ContextNoBody) (*dto.Envelope[dto.OrderSummaryDetailPayload], error) {
	ownerID, err := osc.userIDFromContext(c.Context())
	if err != nil {
		return nil, err
	}
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2699, Message: constant.MsgOrderSummaryNotFound}
	}
	detail, err := osc.orderSummaryService.GetByID(c.Context(), id, ownerID)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*detail, "success", http.StatusOK), nil
}
