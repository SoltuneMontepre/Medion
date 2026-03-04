package controller

import (
	"net/http"

	"backend/internal/dto"
	"backend/internal/service"

	"github.com/go-fuego/fuego"
)

type ProductController struct {
	productService *service.ProductService
}

func NewProductController(productService *service.ProductService) *ProductController {
	return &ProductController{productService: productService}
}

// Suggest returns products for dropdown: ?q=...
func (pc *ProductController) Suggest(c fuego.ContextNoBody) (*dto.Envelope[[]dto.ProductPayload], error) {
	q := c.QueryParam("q")
	list, err := pc.productService.Suggest(c.Context(), q)
	if err != nil {
		return nil, err
	}
	return dto.Ok(list, "success", http.StatusOK), nil
}
