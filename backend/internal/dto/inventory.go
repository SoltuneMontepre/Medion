package dto

import "github.com/google/uuid"

// InventoryPayload is returned in list/get. Includes product info for display (MÃ SP, TÊN, QUY, DẠNG, SỐ).
type InventoryPayload struct {
	ID            uuid.UUID `json:"id"`
	ProductID     uuid.UUID `json:"productId"`
	ProductCode   string    `json:"productCode"`
	ProductName   string    `json:"productName"`
	PackageSize   string    `json:"packageSize"`
	PackageUnit   string    `json:"packageUnit"`
	ProductType   string    `json:"productType"`
	PackagingType string    `json:"packagingType"`
	WarehouseType string    `json:"warehouseType"` // raw | semi | finished
	Quantity      int64     `json:"quantity"`
}
