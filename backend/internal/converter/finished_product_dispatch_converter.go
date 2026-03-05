package converter

import (
	"backend/internal/dto"
	"backend/internal/model"
	"strings"
)

func (c *Converter) FinishedProductDispatchToPayload(d model.FinishedProductDispatch) dto.FinishedProductDispatchPayload {
	items := make([]dto.FinishedProductDispatchLineDetail, len(d.Items))
	for i, it := range d.Items {
		items[i] = c.FinishedProductDispatchLineToDetail(it)
	}
	payload := dto.FinishedProductDispatchPayload{
		ID:              d.ID,
		CustomerID:       d.CustomerID,
		OrderNumber:      d.OrderNumber,
		Address:         d.Address,
		Phone:           d.Phone,
		Status:          d.Status,
		RejectionReason: d.RejectionReason,
		CreatedAt:       d.CreatedAt,
		CreatedBy:       d.CreatedBy,
		ApprovedAt:      d.ApprovedAt,
		ApprovedBy:      d.ApprovedBy,
		Items:           items,
	}
	if d.Customer != nil {
		payload.CustomerCode = d.Customer.Code
		payload.CustomerName = d.Customer.Name
	}
	return payload
}

func (c *Converter) FinishedProductDispatchLineToDetail(line model.FinishedProductDispatchLine) dto.FinishedProductDispatchLineDetail {
	detail := dto.FinishedProductDispatchLineDetail{
		ID:                line.ID,
		ProductID:         line.ProductID,
		Ordinal:           line.Ordinal,
		Quantity:          line.Quantity,
		LotNumber:         line.LotNumber,
		ManufacturingDate: line.ManufacturingDate,
		ExpiryDate:        line.ExpiryDate,
	}
	if line.Product != nil {
		detail.ProductCode = line.Product.Code
		detail.ProductName = line.Product.Name
		detail.Specification = strings.TrimSpace(line.Product.PackageSize + line.Product.PackageUnit)
		detail.ProductForm = line.Product.ProductType
		detail.PackagingForm = line.Product.PackagingType
	}
	return detail
}
