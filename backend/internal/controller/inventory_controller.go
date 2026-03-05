package controller

import (
	"net/http"
	"strconv"

	"backend/internal/dto"
	"backend/internal/service"

	"github.com/go-fuego/fuego"
)

type InventoryController struct {
	inventoryService *service.InventoryService
}

func NewInventoryController(inventoryService *service.InventoryService) *InventoryController {
	return &InventoryController{inventoryService: inventoryService}
}

type listInventoryResponse struct {
	Items []dto.InventoryPayload `json:"items"`
	Total int64                 `json:"total"`
}

func (ic *InventoryController) List(c fuego.ContextNoBody) (*dto.Envelope[listInventoryResponse], error) {
	warehouseType := c.QueryParam("warehouseType")
	page, _ := strconv.Atoi(c.QueryParam("page"))
	if page < 1 {
		page = 1
	}
	pageSize, _ := strconv.Atoi(c.QueryParam("pageSize"))
	if pageSize < 1 {
		pageSize = 20
	}
	items, total, err := ic.inventoryService.List(c.Context(), warehouseType, page, pageSize)
	if err != nil {
		return nil, err
	}
	return dto.Ok(listInventoryResponse{Items: items, Total: total}, "success", http.StatusOK), nil
}

func (ic *InventoryController) GetByID(c fuego.ContextNoBody) (*dto.Envelope[dto.InventoryPayload], error) {
	id := c.PathParam("id")
	data, err := ic.inventoryService.GetByID(c.Context(), id)
	if err != nil {
		return nil, err
	}
	return dto.Ok(data, "success", http.StatusOK), nil
}
