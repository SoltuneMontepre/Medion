package converter

import (
	"backend/internal/dto"
	"backend/internal/model"
	"strings"
)

func (c *Converter) ProductionOrderToPayload(o model.ProductionOrder) dto.ProductionOrderPayload {
	p := dto.ProductionOrderPayload{
		ID:             o.ID,
		OrderNumber:    o.OrderNumber,
		ProductID:      o.ProductID,
		BatchNumber:    o.BatchNumber,
		ProductionDate: o.ProductionDate,
		ExpiryDate:     o.ExpiryDate,
		BatchSizeLit:   o.BatchSizeLit,
		QuantitySpec1:  o.QuantitySpec1,
		QuantitySpec2:  o.QuantitySpec2,
		Status:         o.Status,
		CreatedAt:      o.CreatedAt,
		CreatedBy:      o.CreatedBy,
	}
	if o.Product != nil {
		p.ProductCode = o.Product.Code
		p.ProductName = o.Product.Name
		p.ProductForm = o.Product.ProductType
		p.Specification = strings.TrimSpace(o.Product.PackageSize + o.Product.PackageUnit)
	}
	p.Ingredients = make([]dto.ProductionOrderIngredientPayload, 0, len(o.Ingredients))
	for _, ing := range o.Ingredients {
		ip := dto.ProductionOrderIngredientPayload{
			ID:                 ing.ID,
			IngredientID:      ing.IngredientID,
			Quantity:          ing.Quantity,
			QuantityAdjustment: ing.QuantityAdjustment,
			Unit:              ing.Unit,
			Notes:             ing.Notes,
			Ordinal:           ing.Ordinal,
		}
		if ing.Ingredient != nil {
			ip.IngredientCode = ing.Ingredient.Code
			ip.IngredientName = ing.Ingredient.Name
		}
		p.Ingredients = append(p.Ingredients, ip)
	}
	return p
}
