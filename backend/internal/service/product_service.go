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

type ProductService struct {
	products  *repository.ProductRepository
	converter *converter.Converter
}

func NewProductService(products *repository.ProductRepository, conv *converter.Converter) *ProductService {
	return &ProductService{products: products, converter: conv}
}

// List returns paginated products.
func (s *ProductService) List(ctx context.Context, page, pageSize int) ([]dto.ProductPayload, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	offset := (page - 1) * pageSize
	list, err := s.products.FindAll(ctx, pageSize, offset)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2701, Message: constant.MsgProductServerError, Err: err}
	}
	total, err := s.products.Count(ctx)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2702, Message: constant.MsgProductServerError, Err: err}
	}
	return s.converter.ProductsToPayloads(list), total, nil
}

// GetByID returns one product by id.
func (s *ProductService) GetByID(ctx context.Context, id uuid.UUID) (*dto.ProductPayload, error) {
	p, err := s.products.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2703, Message: constant.MsgProductNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2704, Message: constant.MsgProductServerError, Err: err}
	}
	payload := s.converter.ProductToPayload(*p)
	return &payload, nil
}

// Create creates a new product. Validates code uniqueness.
func (s *ProductService) Create(ctx context.Context, req dto.CreateProductRequest) (*dto.ProductPayload, error) {
	code := strings.TrimSpace(req.Code)
	name := strings.TrimSpace(req.Name)
	if code == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2710, Message: constant.MsgProductCodeRequired}
	}
	if name == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2711, Message: constant.MsgProductNameRequired}
	}
	exists, err := s.products.ExistsByCode(ctx, code)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2712, Message: constant.MsgProductServerError, Err: err}
	}
	if exists {
		return nil, &dto.AppError{HTTPStatus: http.StatusConflict, Code: 2713, Message: constant.MsgProductCodeExists}
	}
	product := model.Product{
		Code:          code,
		Name:          strings.TrimSpace(req.Name),
		PackageSize:   strings.TrimSpace(req.PackageSize),
		PackageUnit:   strings.TrimSpace(req.PackageUnit),
		ProductType:   strings.TrimSpace(req.ProductType),
		PackagingType: strings.TrimSpace(req.PackagingType),
	}
	if product.PackageSize == "" {
		product.PackageSize = "-"
	}
	if product.PackageUnit == "" {
		product.PackageUnit = "-"
	}
	if product.ProductType == "" {
		product.ProductType = "-"
	}
	if product.PackagingType == "" {
		product.PackagingType = "-"
	}
	if err := s.products.Create(ctx, &product); err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2714, Message: constant.MsgProductServerError, Err: err}
	}
	payload := s.converter.ProductToPayload(product)
	return &payload, nil
}

// Update updates a product. Validates code uniqueness when code changes.
func (s *ProductService) Update(ctx context.Context, id uuid.UUID, req dto.UpdateProductRequest) (*dto.ProductPayload, error) {
	code := strings.TrimSpace(req.Code)
	name := strings.TrimSpace(req.Name)
	if code == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2720, Message: constant.MsgProductCodeRequired}
	}
	if name == "" {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2721, Message: constant.MsgProductNameRequired}
	}
	existing, err := s.products.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2722, Message: constant.MsgProductNotFound}
		}
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2723, Message: constant.MsgProductServerError, Err: err}
	}
	if existing.Code != code {
		exists, err := s.products.ExistsByCodeExcludingID(ctx, code, id)
		if err != nil {
			return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2724, Message: constant.MsgProductServerError, Err: err}
		}
		if exists {
			return nil, &dto.AppError{HTTPStatus: http.StatusConflict, Code: 2725, Message: constant.MsgProductCodeExists}
		}
	}
	existing.Code = code
	existing.Name = name
	existing.PackageSize = strings.TrimSpace(req.PackageSize)
	existing.PackageUnit = strings.TrimSpace(req.PackageUnit)
	existing.ProductType = strings.TrimSpace(req.ProductType)
	existing.PackagingType = strings.TrimSpace(req.PackagingType)
	if existing.PackageSize == "" {
		existing.PackageSize = "-"
	}
	if existing.PackageUnit == "" {
		existing.PackageUnit = "-"
	}
	if existing.ProductType == "" {
		existing.ProductType = "-"
	}
	if existing.PackagingType == "" {
		existing.PackagingType = "-"
	}
	if err := s.products.Update(ctx, existing); err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2726, Message: constant.MsgProductServerError, Err: err}
	}
	payload := s.converter.ProductToPayload(*existing)
	return &payload, nil
}

// Delete soft-deletes a product.
func (s *ProductService) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := s.products.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2730, Message: constant.MsgProductNotFound}
		}
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2731, Message: constant.MsgProductServerError, Err: err}
	}
	if err := s.products.Delete(ctx, id); err != nil {
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2732, Message: constant.MsgProductServerError, Err: err}
	}
	return nil
}

// Suggest returns products matching query (code or name) for dropdown. Limit 20.
func (s *ProductService) Suggest(ctx context.Context, query string) ([]dto.ProductPayload, error) {
	query = strings.TrimSpace(query)
	if len(query) < 1 {
		return []dto.ProductPayload{}, nil
	}
	list, err := s.products.SearchByCodeName(ctx, query, 20)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2701, Message: constant.MsgProductServerError, Err: err}
	}
	return s.converter.ProductsToPayloads(list), nil
}
