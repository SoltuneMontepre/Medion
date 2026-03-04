package converter

import (
	"backend/internal/dto"
	"backend/internal/model"
)

func (c *Converter) OrderSummaryToPayload(os model.OrderSummary, itemCount int) dto.OrderSummaryPayload {
	return dto.OrderSummaryPayload{
		ID:          os.ID,
		OwnerID:     os.OwnerID,
		SummaryDate: os.SummaryDate,
		CreatedAt:   os.CreatedAt,
		CreatedBy:   os.CreatedBy,
		ApprovedBy:  os.ApprovedBy,
		ItemCount:   itemCount,
	}
}

func (c *Converter) OrderSummaryToDetailPayload(os model.OrderSummary, items []dto.OrderSummaryItemDetail) dto.OrderSummaryDetailPayload {
	return dto.OrderSummaryDetailPayload{
		OrderSummaryPayload: c.OrderSummaryToPayload(os, len(items)),
		Items:               items,
	}
}

func (c *Converter) OrderSummaryItemToDetail(osi model.OrderSummaryItem) dto.OrderSummaryItemDetail {
	detail := dto.OrderSummaryItemDetail{
		ProductID:  osi.ProductID,
		Quantity:   osi.Quantity,
	}
	if osi.Product != nil {
		detail.ProductCode = osi.Product.Code
		detail.ProductName = osi.Product.Name
		detail.PackageSize = osi.Product.PackageSize
		detail.PackageUnit = osi.Product.PackageUnit
		detail.ProductType = osi.Product.ProductType
		detail.PackagingType = osi.Product.PackagingType
	}
	return detail
}
