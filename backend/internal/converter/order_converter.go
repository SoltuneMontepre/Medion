package converter

import (
	"backend/internal/dto"
	"backend/internal/model"
)

func (c *Converter) OrderToPayload(o model.Order, customerCode, customerName string) dto.OrderPayload {
	return dto.OrderPayload{
		ID:            o.ID,
		OrderNumber:   o.OrderNumber,
		CustomerID:    o.CustomerID,
		CustomerCode:  customerCode,
		CustomerName:  customerName,
		OrderDate:     o.OrderDate,
		Status:        o.Status,
	}
}

func (c *Converter) OrderToDetailPayload(o model.Order, customerCode, customerName string, items []dto.OrderItemDetail) dto.OrderDetailPayload {
	return dto.OrderDetailPayload{
		OrderPayload: c.OrderToPayload(o, customerCode, customerName),
		Items:        items,
	}
}

func (c *Converter) OrderItemToDetail(oi model.OrderItem) dto.OrderItemDetail {
	detail := dto.OrderItemDetail{
		ProductID:     oi.ProductID,
		Quantity:      oi.Quantity,
	}
	if oi.Product != nil {
		detail.ProductCode = oi.Product.Code
		detail.ProductName = oi.Product.Name
		detail.PackageSize = oi.Product.PackageSize
		detail.PackageUnit = oi.Product.PackageUnit
		detail.ProductType = oi.Product.ProductType
		detail.PackagingType = oi.Product.PackagingType
	}
	return detail
}
