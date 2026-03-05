package converter

import (
	"backend/internal/dto"
	"backend/internal/model"
)

func (c *Converter) IngredientToPayload(i model.Ingredient) dto.IngredientPayload {
	return dto.IngredientPayload{
		ID:          i.ID,
		Code:        i.Code,
		Name:        i.Name,
		Unit:        i.Unit,
		Description: i.Description,
	}
}

func (c *Converter) IngredientsToPayloads(list []model.Ingredient) []dto.IngredientPayload {
	payloads := make([]dto.IngredientPayload, len(list))
	for i, ing := range list {
		payloads[i] = c.IngredientToPayload(ing)
	}
	return payloads
}
