package service

import (
	"context"
	"errors"

	"backend/internal/converter"
	"backend/internal/dto"
	"backend/internal/model"
	"backend/internal/repository"

	"gorm.io/gorm"
)

type CompanyService struct {
	companies *repository.CompanyRepository
	converter *converter.Converter
}

func NewCompanyService(companies *repository.CompanyRepository, conv *converter.Converter) *CompanyService {
	return &CompanyService{companies: companies, converter: conv}
}

// List returns all active companies for dropdown/selection.
func (s *CompanyService) List(ctx context.Context) ([]dto.CompanyPayload, error) {
	list, err := s.companies.FindAll(ctx)
	if err != nil {
		return nil, err
	}
	return s.converter.CompaniesToPayloads(list), nil
}

// GetByID returns a company by ID (for validation when creating department).
func (s *CompanyService) GetByID(ctx context.Context, id string) (*model.Company, error) {
	return s.companies.FindByID(ctx, id)
}

// Exists returns true if the company exists. Used by department service.
func (s *CompanyService) Exists(ctx context.Context, id string) (bool, error) {
	_, err := s.companies.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return false, nil
		}
		return false, err
	}
	return true, nil
}
