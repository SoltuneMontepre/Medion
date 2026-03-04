package controller

import (
	"net/http"
	"strconv"

	"backend/internal/constant"
	"backend/internal/dto"
	"backend/internal/service"

	"github.com/go-fuego/fuego"
	"github.com/google/uuid"
)

type ProductController struct {
	productService *service.ProductService
}

func NewProductController(productService *service.ProductService) *ProductController {
	return &ProductController{productService: productService}
}

type listProductsResponse struct {
	Items []dto.ProductPayload `json:"items"`
	Total int64                `json:"total"`
}

// List returns paginated products: ?page=1&pageSize=20
func (pc *ProductController) List(c fuego.ContextNoBody) (*dto.Envelope[listProductsResponse], error) {
	page, _ := strconv.Atoi(c.QueryParam("page"))
	if page < 1 {
		page = 1
	}
	pageSize, _ := strconv.Atoi(c.QueryParam("pageSize"))
	if pageSize < 1 {
		pageSize = 20
	}
	items, total, err := pc.productService.List(c.Context(), page, pageSize)
	if err != nil {
		return nil, err
	}
	return dto.Ok(listProductsResponse{Items: items, Total: total}, "success", http.StatusOK), nil
}

// GetByID returns one product by id.
func (pc *ProductController) GetByID(c fuego.ContextNoBody) (*dto.Envelope[dto.ProductPayload], error) {
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2799, Message: constant.MsgProductNotFound}
	}
	payload, err := pc.productService.GetByID(c.Context(), id)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, "success", http.StatusOK), nil
}

// Create creates a new product.
func (pc *ProductController) Create(c fuego.ContextWithBody[dto.CreateProductRequest]) (*dto.Envelope[dto.ProductPayload], error) {
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	payload, err := pc.productService.Create(c.Context(), body)
	if err != nil {
		return nil, err
	}
	c.SetStatus(http.StatusCreated)
	return dto.Ok(*payload, constant.MsgProductSaveSuccess, http.StatusCreated), nil
}

// Update updates a product.
func (pc *ProductController) Update(c fuego.ContextWithBody[dto.UpdateProductRequest]) (*dto.Envelope[dto.ProductPayload], error) {
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2799, Message: constant.MsgProductNotFound}
	}
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	payload, err := pc.productService.Update(c.Context(), id, body)
	if err != nil {
		return nil, err
	}
	return dto.Ok(*payload, constant.MsgProductSaveSuccess, http.StatusOK), nil
}

// Delete soft-deletes a product.
func (pc *ProductController) Delete(c fuego.ContextNoBody) (*dto.Envelope[any], error) {
	idStr := c.PathParam("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2799, Message: constant.MsgProductNotFound}
	}
	if err := pc.productService.Delete(c.Context(), id); err != nil {
		return nil, err
	}
	return dto.Ok[any](nil, constant.MsgProductDeleteSuccess, http.StatusOK), nil
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
