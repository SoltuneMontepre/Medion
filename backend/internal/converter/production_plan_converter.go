package converter

import (
	"backend/internal/dto"
	"backend/internal/model"
	"strings"
)

func (c *Converter) ProductionPlanToPayload(plan model.ProductionPlan) dto.ProductionPlanPayload {
	items := make([]dto.ProductionPlanItemDetail, len(plan.Items))
	for i, it := range plan.Items {
		items[i] = c.ProductionPlanItemToDetail(it)
	}
	return dto.ProductionPlanPayload{
		ID:         plan.ID,
		PlanDate:   plan.PlanDate,
		Status:     plan.Status,
		CreatedAt:  plan.CreatedAt,
		CreatedBy:  plan.CreatedBy,
		ApprovedAt: plan.ApprovedAt,
		ApprovedBy: plan.ApprovedBy,
		Items:      items,
	}
}

func (c *Converter) ProductionPlanItemToDetail(item model.ProductionPlanItem) dto.ProductionPlanItemDetail {
	detail := dto.ProductionPlanItemDetail{
		ID:              item.ID,
		ProductID:       item.ProductID,
		Ordinal:         item.Ordinal,
		PlannedQuantity: item.PlannedQuantity,
	}
	if item.Product != nil {
		detail.ProductCode = item.Product.Code
		detail.ProductName = item.Product.Name
		detail.Specification = strings.TrimSpace(item.Product.PackageSize + item.Product.PackageUnit)
		detail.ProductForm = item.Product.ProductType
		detail.PackagingForm = item.Product.PackagingType
	}
	return detail
}
