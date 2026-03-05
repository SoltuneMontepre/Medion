package controller

import (
	"net/http"
	"strconv"

	"backend/internal/constant"
	"backend/internal/dto"
	"backend/internal/service"

	"github.com/go-fuego/fuego"
	"github.com/google/uuid"
)

type IngredientController struct {
	ingredientService *service.IngredientService
}

func NewIngredientController(ingredientService *service.IngredientService) *IngredientController {
	return &IngredientController{ingredientService: ingredientService}
}

type listIngredientsResponse struct {
	Items []dto.IngredientPayload `json:"items"`
	Total int64                   `json:"total"`
}

// List returns paginated ingredients: ?page=1&pageSize=20
func (ic *IngredientController) List(c fuego.ContextNoBody) (*dto.Envelope[listIngredientsResponse], error) {
	page, _ := strconv.Atoi(c.QueryParam("page"))
	if page < 1 {
		page = 1
	}
	pageSize, _ := strconv.Atoi(c.QueryParam("pageSize"))
	if pageSize < 1 {
		pageSize = 20
	}
	items, total, err := ic.ingredientService.List(c.Context(), page, pageSize)
	if err != nil {
		return nil, err
	}
	return dto.Ok(listIngredientsResponse{Items: items, Total: total}, "success", http.StatusOK), nil
}

// GetByID returns one ingredient by id.
func (ic *IngredientController) GetByID(c fuego.ContextNoBody) (*dto.Envelope[dto.IngredientPayload], error) {
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2799, Message: constant.MsgIngredientNotFound}
	}
	payload, err := ic.ingredientService.GetByID(c.Context(), id)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}

// Create creates a new ingredient.
func (ic *IngredientController) Create(c fuego.ContextWithBody[dto.CreateIngredientRequest]) (*dto.Envelope[dto.IngredientPayload], error) {
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	payload, err := ic.ingredientService.Create(c.Context(), body)
	if err != nil {
		return nil, err
	}
	c.SetStatus(http.StatusCreated)
	return dto.Ok(*payload, "success", http.StatusCreated), nil
}

// Update updates an ingredient.
func (ic *IngredientController) Update(c fuego.ContextWithBody[dto.UpdateIngredientRequest]) (*dto.Envelope[dto.IngredientPayload], error) {
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2799, Message: constant.MsgIngredientNotFound}
	}
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	payload, err := ic.ingredientService.Update(c.Context(), id, body)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}

// Delete soft-deletes an ingredient.
func (ic *IngredientController) Delete(c fuego.ContextNoBody) (*dto.Envelope[any], error) {
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2799, Message: constant.MsgIngredientNotFound}
	}
	if err := ic.ingredientService.Delete(c.Context(), id); err != nil {
		return nil, err
	}
	return dto.Ok[any](nil, "success", http.StatusOK), nil
}

// Suggest returns ingredients for dropdown: ?q=...
func (ic *IngredientController) Suggest(c fuego.ContextNoBody) (*dto.Envelope[[]dto.IngredientPayload], error) {
	q := c.QueryParam("q")
	list, err := ic.ingredientService.Suggest(c.Context(), q)
	if err != nil {
		return nil, err
	}
	return dto.Ok(list, "success", http.StatusOK), nil
}
