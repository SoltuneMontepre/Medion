package controller

import (
	"context"
	"net/http"

	"backend/internal/constant"
	"backend/internal/dto"
	"backend/internal/middleware"
	"backend/internal/security"
	"backend/internal/service"

	"github.com/go-fuego/fuego"
	"github.com/google/uuid"
)

type ProductionPlanController struct {
	productionPlanService *service.ProductionPlanService
	jwtManager            *security.JWTManager
}

func NewProductionPlanController(productionPlanService *service.ProductionPlanService, jwtManager *security.JWTManager) *ProductionPlanController {
	return &ProductionPlanController{
		productionPlanService: productionPlanService,
		jwtManager:            jwtManager,
	}
}

func (pc *ProductionPlanController) userIDFromContext(ctx context.Context) (uuid.UUID, error) {
	token, ok := middleware.GetAccessTokenFromContext(ctx)
	if !ok {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1011, Message: "access token is missing"}
	}
	claims, err := pc.jwtManager.ParseAccessToken(token)
	if err != nil {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1012, Message: "invalid or expired access token", Err: err}
	}
	id, err := uuid.Parse(claims.Subject)
	if err != nil {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1013, Message: "invalid user id in token", Err: err}
	}
	return id, nil
}

// GetByDate returns the production plan for the given date (query: date=YYYY-MM-DD). Returns 200 with null data if no plan.
func (pc *ProductionPlanController) GetByDate(c fuego.ContextNoBody) (*dto.Envelope[*dto.ProductionPlanPayload], error) {
	dateStr := c.QueryParam("date")
	if dateStr == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2720, Message: constant.MsgProductionPlanDateRequired}
	}
	payload, err := pc.productionPlanService.GetByDate(c.Context(), dateStr)
	if err != nil {
		return nil, err
	}
	return dto.Ok(payload, "success", http.StatusOK), nil
}

// GetByID returns the production plan by id.
func (pc *ProductionPlanController) GetByID(c fuego.ContextNoBody) (*dto.Envelope[dto.ProductionPlanPayload], error) {
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2721, Message: constant.MsgProductionPlanNotFound}
	}
	payload, err := pc.productionPlanService.GetByID(c.Context(), id)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}

// Create creates a new production plan (body: planDate YYYY-MM-DD, items).
func (pc *ProductionPlanController) Create(c fuego.ContextWithBody[dto.CreateProductionPlanRequest]) (*dto.Envelope[dto.ProductionPlanPayload], error) {
	userID, err := pc.userIDFromContext(c.Context())
	if err != nil {
		return nil, err
	}
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	payload, err := pc.productionPlanService.Create(c.Context(), &body, userID)
	if err != nil {
		return nil, err
	}
	c.SetStatus(http.StatusCreated)
	return dto.Ok(*payload, "success", http.StatusCreated), nil
}

// Update updates an existing production plan by id.
func (pc *ProductionPlanController) Update(c fuego.ContextWithBody[dto.UpdateProductionPlanRequest]) (*dto.Envelope[dto.ProductionPlanPayload], error) {
	userID, err := pc.userIDFromContext(c.Context())
	if err != nil {
		return nil, err
	}
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2722, Message: constant.MsgProductionPlanNotFound}
	}
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	payload, err := pc.productionPlanService.Update(c.Context(), id, &body, userID)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}

// Submit moves a plan from draft to submitted.
func (pc *ProductionPlanController) Submit(c fuego.ContextNoBody) (*dto.Envelope[dto.ProductionPlanPayload], error) {
	userID, err := pc.userIDFromContext(c.Context())
	if err != nil {
		return nil, err
	}
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2722, Message: constant.MsgProductionPlanNotFound}
	}
	payload, err := pc.productionPlanService.Submit(c.Context(), id, userID)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}

// Approve moves a plan from submitted to approved.
func (pc *ProductionPlanController) Approve(c fuego.ContextNoBody) (*dto.Envelope[dto.ProductionPlanPayload], error) {
	userID, err := pc.userIDFromContext(c.Context())
	if err != nil {
		return nil, err
	}
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2722, Message: constant.MsgProductionPlanNotFound}
	}
	payload, err := pc.productionPlanService.Approve(c.Context(), id, userID)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}

// Reject moves a plan from submitted back to draft (không duyệt).
func (pc *ProductionPlanController) Reject(c fuego.ContextWithBody[dto.RejectProductionPlanRequest]) (*dto.Envelope[dto.ProductionPlanPayload], error) {
	userID, err := pc.userIDFromContext(c.Context())
	if err != nil {
		return nil, err
	}
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2722, Message: constant.MsgProductionPlanNotFound}
	}
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	payload, err := pc.productionPlanService.Reject(c.Context(), id, userID, body.Reason)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}
