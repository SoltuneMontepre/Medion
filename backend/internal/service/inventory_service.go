package service

import (
	"context"
	"errors"
	"net/http"

	"backend/internal/constant"
	"backend/internal/converter"
	"backend/internal/dto"
	"backend/internal/model"
	"backend/internal/repository"

	"gorm.io/gorm"
)

type InventoryService struct {
	repo     *repository.InventoryRepository
	converter *converter.Converter
}

func NewInventoryService(repo *repository.InventoryRepository, conv *converter.Converter) *InventoryService {
	return &InventoryService{repo: repo, converter: conv}
}

// ValidWarehouseTypes for query validation.
var ValidWarehouseTypes = map[string]bool{
	model.WarehouseTypeRaw: true, model.WarehouseTypeSemi: true, model.WarehouseTypeFinished: true,
}

func (s *InventoryService) List(ctx context.Context, warehouseType string, page, pageSize int) ([]dto.InventoryPayload, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	if warehouseType != "" && !ValidWarehouseTypes[warehouseType] {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 4001, Message: constant.MsgInventoryInvalidWarehouse}
	}
	offset := (page - 1) * pageSize
	list, err := s.repo.FindAll(ctx, warehouseType, pageSize, offset)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 4501, Message: "failed to list inventory", Err: err}
	}
	total, err := s.repo.Count(ctx, warehouseType)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 4502, Message: "failed to count inventory", Err: err}
	}
	return s.converter.InventoriesToPayloads(list), total, nil
}

func (s *InventoryService) GetByID(ctx context.Context, id string) (dto.InventoryPayload, error) {
	inv, err := s.repo.FindByIDWithProduct(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.InventoryPayload{}, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 4002, Message: constant.MsgInventoryNotFound}
		}
		return dto.InventoryPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 4503, Message: "failed to get inventory", Err: err}
	}
	return s.converter.InventoryToPayload(*inv), nil
}
