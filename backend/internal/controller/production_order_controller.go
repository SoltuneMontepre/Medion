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

type ProductionOrderController struct {
	service    *service.ProductionOrderService
	jwtManager *security.JWTManager
}

func NewProductionOrderController(svc *service.ProductionOrderService, jwtManager *security.JWTManager) *ProductionOrderController {
	return &ProductionOrderController{service: svc, jwtManager: jwtManager}
}

func (c *ProductionOrderController) userIDFromContext(ctx context.Context) (uuid.UUID, error) {
	token, ok := middleware.GetAccessTokenFromContext(ctx)
	if !ok {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1011, Message: "access token is missing"}
	}
	claims, err := c.jwtManager.ParseAccessToken(token)
	if err != nil {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1012, Message: "invalid or expired access token", Err: err}
	}
	id, err := uuid.Parse(claims.Subject)
	if err != nil {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1013, Message: "invalid user id in token", Err: err}
	}
	return id, nil
}

// List returns paginated production orders.
func (c *ProductionOrderController) List(fc fuego.ContextNoBody) (*dto.Envelope[dto.ProductionOrderListResponse], error) {
	limit, _ := strconv.Atoi(fc.QueryParam("limit"))
	if limit <= 0 {
		limit = 20
	}
	offset, _ := strconv.Atoi(fc.QueryParam("offset"))
	if offset < 0 {
		offset = 0
	}
	status := fc.QueryParam("status")
	resp, err := c.service.List(fc.Context(), status, limit, offset)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*resp, "success", http.StatusOK), nil
}

// GetByID returns a production order by id.
func (c *ProductionOrderController) GetByID(fc fuego.ContextNoBody) (*dto.Envelope[dto.ProductionOrderPayload], error) {
	idStr := fc.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2732, Message: constant.MsgProductionOrderNotFound}
	}
	payload, err := c.service.GetByID(fc.Context(), id)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}

// Create creates a new production order (1 product per order).
func (c *ProductionOrderController) Create(fc fuego.ContextWithBody[dto.CreateProductionOrderRequest]) (*dto.Envelope[dto.ProductionOrderPayload], error) {
	userID, err := c.userIDFromContext(fc.Context())
	if err != nil {
		return nil, err
	}
	body, err := fc.Body()
	if err != nil {
		return nil, err
	}
	payload, err := c.service.Create(fc.Context(), &body, userID)
	if err != nil {
		return nil, err
	}
	fc.SetStatus(http.StatusCreated)
	return dto.Ok(*payload, "success", http.StatusCreated), nil
}

// Update updates a draft production order.
func (c *ProductionOrderController) Update(fc fuego.ContextWithBody[dto.UpdateProductionOrderRequest]) (*dto.Envelope[dto.ProductionOrderPayload], error) {
	userID, err := c.userIDFromContext(fc.Context())
	if err != nil {
		return nil, err
	}
	idStr := fc.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2732, Message: constant.MsgProductionOrderNotFound}
	}
	body, err := fc.Body()
	if err != nil {
		return nil, err
	}
	payload, err := c.service.Update(fc.Context(), id, &body, userID)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}
