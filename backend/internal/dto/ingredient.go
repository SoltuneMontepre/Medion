package dto

import "github.com/google/uuid"

// IngredientPayload for list/get/suggest responses.
type IngredientPayload struct {
	ID          uuid.UUID `json:"id"`
	Code        string    `json:"code"`
	Name        string    `json:"name"`
	Unit        string    `json:"unit"`
	Description string    `json:"description"`
}

// CreateIngredientRequest for POST /ingredients.
type CreateIngredientRequest struct {
	Code        string `json:"code"`
	Name        string `json:"name"`
	Unit        string `json:"unit"`
	Description string `json:"description"`
}

// UpdateIngredientRequest for PUT /ingredients/:id.
type UpdateIngredientRequest struct {
	Code        string `json:"code"`
	Name        string `json:"name"`
	Unit        string `json:"unit"`
	Description string `json:"description"`
}
