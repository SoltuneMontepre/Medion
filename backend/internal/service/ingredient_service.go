package service

import (
	"context"
	"errors"
	"net/http"
	"strings"

	"backend/internal/constant"
	"backend/internal/converter"
	"backend/internal/dto"
	"backend/internal/model"
	"backend/internal/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type IngredientService struct {
	ingredients *repository.IngredientRepository
	converter   *converter.Converter
}

func NewIngredientService(ingredients *repository.IngredientRepository, conv *converter.Converter) *IngredientService {
	return &IngredientService{ingredients: ingredients, converter: conv}
}

// List returns paginated ingredients.
func (s *IngredientService) List(ctx context.Context, page, pageSize int) ([]dto.IngredientPayload, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	offset := (page - 1) * pageSize
	list, err := s.ingredients.FindAll(ctx, pageSize, offset)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2751, Message: constant.MsgIngredientServerError, Err: err}
	}
	total, err := s.ingredients.Count(ctx)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2752, Message: constant.MsgIngredientServerError, Err: err}
	}
	return s.converter.IngredientsToPayloads(list), total, nil
}

// GetByID returns one ingredient by id.
func (s *IngredientService) GetByID(ctx context.Context, id uuid.UUID) (*dto.IngredientPayload, error) {
	ing, err := s.ingredients.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2753, Message: constant.MsgIngredientNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2754, Message: constant.MsgIngredientServerError, Err: err}
	}
	p := s.converter.IngredientToPayload(*ing)
	return &p, nil
}

// Create creates a new ingredient. Validates code uniqueness.
func (s *IngredientService) Create(ctx context.Context, req dto.CreateIngredientRequest) (*dto.IngredientPayload, error) {
	code := strings.TrimSpace(req.Code)
	name := strings.TrimSpace(req.Name)
	if code == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2760, Message: constant.MsgIngredientCodeRequired}
	}
	if name == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2761, Message: constant.MsgIngredientNameRequired}
	}
	exists, err := s.ingredients.ExistsByCode(ctx, code)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2762, Message: constant.MsgIngredientServerError, Err: err}
	}
	if exists {
		return nil, &dto.AppError{HTTPStatus: http.StatusConflict, Code: 2763, Message: constant.MsgIngredientCodeExists}
	}
	unit := strings.TrimSpace(req.Unit)
	if unit == "" {
		unit = "kg"
	}
	ing := model.Ingredient{
		Code:        code,
		Name:        name,
		Unit:        unit,
		Description: strings.TrimSpace(req.Description),
	}
	if err := s.ingredients.Create(ctx, &ing); err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2764, Message: constant.MsgIngredientServerError, Err: err}
	}
	p := s.converter.IngredientToPayload(ing)
	return &p, nil
}

// Update updates an ingredient. Validates code uniqueness when code changes.
func (s *IngredientService) Update(ctx context.Context, id uuid.UUID, req dto.UpdateIngredientRequest) (*dto.IngredientPayload, error) {
	code := strings.TrimSpace(req.Code)
	name := strings.TrimSpace(req.Name)
	if code == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2770, Message: constant.MsgIngredientCodeRequired}
	}
	if name == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2771, Message: constant.MsgIngredientNameRequired}
	}
	existing, err := s.ingredients.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2772, Message: constant.MsgIngredientNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2773, Message: constant.MsgIngredientServerError, Err: err}
	}
	if existing.Code != code {
		exists, err := s.ingredients.ExistsByCodeExcludingID(ctx, code, id)
		if err != nil {
			return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2774, Message: constant.MsgIngredientServerError, Err: err}
		}
		if exists {
			return nil, &dto.AppError{HTTPStatus: http.StatusConflict, Code: 2775, Message: constant.MsgIngredientCodeExists}
		}
	}
	unit := strings.TrimSpace(req.Unit)
	if unit == "" {
		unit = "kg"
	}
	existing.Code = code
	existing.Name = name
	existing.Unit = unit
	existing.Description = strings.TrimSpace(req.Description)
	if err := s.ingredients.Update(ctx, existing); err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2776, Message: constant.MsgIngredientServerError, Err: err}
	}
	p := s.converter.IngredientToPayload(*existing)
	return &p, nil
}

// Delete soft-deletes an ingredient.
func (s *IngredientService) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := s.ingredients.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2780, Message: constant.MsgIngredientNotFound}
		}
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2781, Message: constant.MsgIngredientServerError, Err: err}
	}
	if err := s.ingredients.Delete(ctx, id); err != nil {
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2782, Message: constant.MsgIngredientServerError, Err: err}
	}
	return nil
}

// Suggest returns ingredients matching query (code or name) for dropdown. Limit 20.
func (s *IngredientService) Suggest(ctx context.Context, query string) ([]dto.IngredientPayload, error) {
	query = strings.TrimSpace(query)
	if len(query) < 1 {
		return []dto.IngredientPayload{}, nil
	}
	list, err := s.ingredients.SearchByCodeName(ctx, query, 20)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2751, Message: constant.MsgIngredientServerError, Err: err}
	}
	return s.converter.IngredientsToPayloads(list), nil
}
