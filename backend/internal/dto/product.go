package dto

import "github.com/google/uuid"

// ProductPayload for list/suggest responses.
type ProductPayload struct {
	ID            uuid.UUID `json:"id"`
	Code          string    `json:"code"`
	Name          string    `json:"name"`
	PackageSize   string    `json:"packageSize"`
	PackageUnit   string    `json:"packageUnit"`
	ProductType   string    `json:"productType"`
	PackagingType string    `json:"packagingType"`
}
