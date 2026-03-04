package service

import (
	"context"
	"net/http"
	"strings"

	"backend/internal/constant"
	"backend/internal/converter"
	"backend/internal/dto"
	"backend/internal/repository"
)

type ProductService struct {
	products  *repository.ProductRepository
	converter *converter.Converter
}

func NewProductService(products *repository.ProductRepository, conv *converter.Converter) *ProductService {
	return &ProductService{products: products, converter: conv}
}

// Suggest returns products matching query (code or name) for dropdown. Limit 20.
func (s *ProductService) Suggest(ctx context.Context, query string) ([]dto.ProductPayload, error) {
	query = strings.TrimSpace(query)
	if len(query) < 1 {
		return []dto.ProductPayload{}, nil
	}
	list, err := s.products.SearchByCodeName(ctx, query, 20)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2601, Message: constant.MsgOrderServerError, Err: err}
	}
	return s.converter.ProductsToPayloads(list), nil
}
