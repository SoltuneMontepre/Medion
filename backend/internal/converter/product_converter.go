package converter

import (
	"backend/internal/dto"
	"backend/internal/model"
)

func (c *Converter) ProductToPayload(p model.Product) dto.ProductPayload {
	return dto.ProductPayload{
		ID:            p.ID,
		Code:          p.Code,
		Name:          p.Name,
		PackageSize:   p.PackageSize,
		PackageUnit:   p.PackageUnit,
		ProductType:   p.ProductType,
		PackagingType: p.PackagingType,
	}
}

func (c *Converter) ProductsToPayloads(products []model.Product) []dto.ProductPayload {
	payloads := make([]dto.ProductPayload, len(products))
	for i, p := range products {
		payloads[i] = c.ProductToPayload(p)
	}
	return payloads
}
