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

type FinishedProductDispatchController struct {
	service   *service.FinishedProductDispatchService
	jwtManager *security.JWTManager
}

func NewFinishedProductDispatchController(service *service.FinishedProductDispatchService, jwtManager *security.JWTManager) *FinishedProductDispatchController {
	return &FinishedProductDispatchController{service: service, jwtManager: jwtManager}
}

func (fc *FinishedProductDispatchController) userIDFromContext(ctx context.Context) (uuid.UUID, error) {
	token, ok := middleware.GetAccessTokenFromContext(ctx)
	if !ok {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1011, Message: "access token is missing"}
	}
	claims, err := fc.jwtManager.ParseAccessToken(token)
	if err != nil {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1012, Message: "invalid or expired access token", Err: err}
	}
	id, err := uuid.Parse(claims.Subject)
	if err != nil {
		return uuid.Nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 1013, Message: "invalid user id in token", Err: err}
	}
	return id, nil
}

// List returns paginated dispatches (query: status, limit, offset).
func (fc *FinishedProductDispatchController) List(c fuego.ContextNoBody) (*dto.Envelope[dto.FinishedProductDispatchListResponse], error) {
	status := c.QueryParam("status")
	limit, _ := strconv.Atoi(c.QueryParam("limit"))
	offset, _ := strconv.Atoi(c.QueryParam("offset"))
	resp, err := fc.service.List(c.Context(), status, limit, offset)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*resp, "success", http.StatusOK), nil
}

// GetByID returns a dispatch by id.
func (fc *FinishedProductDispatchController) GetByID(c fuego.ContextNoBody) (*dto.Envelope[dto.FinishedProductDispatchPayload], error) {
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2801, Message: constant.MsgDispatchNotFound}
	}
	payload, err := fc.service.GetByID(c.Context(), id)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}

// Create creates a new dispatch (draft).
func (fc *FinishedProductDispatchController) Create(c fuego.ContextWithBody[dto.CreateFinishedProductDispatchRequest]) (*dto.Envelope[dto.FinishedProductDispatchPayload], error) {
	userID, err := fc.userIDFromContext(c.Context())
	if err != nil {
		return nil, err
	}
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	payload, err := fc.service.Create(c.Context(), &body, userID)
	if err != nil {
		return nil, err
	}
	c.SetStatus(http.StatusCreated)
	return dto.Ok(*payload, "success", http.StatusCreated), nil
}

// Update updates a dispatch (draft or revision_requested).
func (fc *FinishedProductDispatchController) Update(c fuego.ContextWithBody[dto.UpdateFinishedProductDispatchRequest]) (*dto.Envelope[dto.FinishedProductDispatchPayload], error) {
	userID, err := fc.userIDFromContext(c.Context())
	if err != nil {
		return nil, err
	}
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2801, Message: constant.MsgDispatchNotFound}
	}
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	payload, err := fc.service.Update(c.Context(), id, &body, userID)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}

// Submit moves draft/revision_requested to pending_approval.
func (fc *FinishedProductDispatchController) Submit(c fuego.ContextNoBody) (*dto.Envelope[dto.FinishedProductDispatchPayload], error) {
	userID, err := fc.userIDFromContext(c.Context())
	if err != nil {
		return nil, err
	}
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2801, Message: constant.MsgDispatchNotFound}
	}
	payload, err := fc.service.Submit(c.Context(), id, userID)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}

// Approve moves pending_approval to approved.
func (fc *FinishedProductDispatchController) Approve(c fuego.ContextNoBody) (*dto.Envelope[dto.FinishedProductDispatchPayload], error) {
	userID, err := fc.userIDFromContext(c.Context())
	if err != nil {
		return nil, err
	}
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2801, Message: constant.MsgDispatchNotFound}
	}
	payload, err := fc.service.Approve(c.Context(), id, userID)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}

// Reject moves pending_approval to revision_requested with reason.
func (fc *FinishedProductDispatchController) Reject(c fuego.ContextWithBody[dto.RejectFinishedProductDispatchRequest]) (*dto.Envelope[dto.FinishedProductDispatchPayload], error) {
	userID, err := fc.userIDFromContext(c.Context())
	if err != nil {
		return nil, err
	}
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2801, Message: constant.MsgDispatchNotFound}
	}
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	payload, err := fc.service.Reject(c.Context(), id, userID, body.Reason)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}
