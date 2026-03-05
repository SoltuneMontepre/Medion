package converter

import (
	"backend/internal/dto"
	"backend/internal/model"
)

func (c *Converter) InventoryToPayload(inv model.Inventory) dto.InventoryPayload {
	payload := dto.InventoryPayload{
		ID:            inv.ID,
		ProductID:     inv.ProductID,
		WarehouseType: inv.WarehouseType,
		Quantity:      inv.Quantity,
	}
	if inv.Product != nil {
		payload.ProductCode = inv.Product.Code
		payload.ProductName = inv.Product.Name
		payload.PackageSize = inv.Product.PackageSize
		payload.PackageUnit = inv.Product.PackageUnit
		payload.ProductType = inv.Product.ProductType
		payload.PackagingType = inv.Product.PackagingType
	}
	return payload
}

func (c *Converter) InventoriesToPayloads(list []model.Inventory) []dto.InventoryPayload {
	payloads := make([]dto.InventoryPayload, len(list))
	for i, inv := range list {
		payloads[i] = c.InventoryToPayload(inv)
	}
	return payloads
}
