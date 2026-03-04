package dto

import "github.com/google/uuid"

// ProductPayload for list/suggest/get responses.
type ProductPayload struct {
	ID            uuid.UUID `json:"id"`
	Code          string    `json:"code"`
	Name          string    `json:"name"`
	PackageSize   string    `json:"packageSize"`
	PackageUnit   string    `json:"packageUnit"`
	ProductType   string    `json:"productType"`
	PackagingType string    `json:"packagingType"`
}

// CreateProductRequest for POST /sale/products.
type CreateProductRequest struct {
	Code          string `json:"code"`
	Name          string `json:"name"`
	PackageSize   string `json:"packageSize"`
	PackageUnit   string `json:"packageUnit"`
	ProductType   string `json:"productType"`
	PackagingType string `json:"packagingType"`
}

// UpdateProductRequest for PUT /sale/products/:id.
type UpdateProductRequest struct {
	Code          string `json:"code"`
	Name          string `json:"name"`
	PackageSize   string `json:"packageSize"`
	PackageUnit   string `json:"packageUnit"`
	ProductType   string `json:"productType"`
	PackagingType string `json:"packagingType"`
}
