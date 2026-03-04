package controller

import (
	"net/http"
	"strconv"

	"backend/internal/constant"
	"backend/internal/dto"
	"backend/internal/service"

	"github.com/go-fuego/fuego"
)

type CustomerController struct {
	customerService *service.CustomerService
}

func NewCustomerController(customerService *service.CustomerService) *CustomerController {
	return &CustomerController{customerService: customerService}
}

type listCustomersResponse struct {
	Items []dto.CustomerPayload `json:"items"`
	Total int64                 `json:"total"`
}

func (cc *CustomerController) List(c fuego.ContextNoBody) (*dto.Envelope[listCustomersResponse], error) {
	page, _ := strconv.Atoi(c.QueryParam("page"))
	if page < 1 {
		page = 1
	}
	pageSize, _ := strconv.Atoi(c.QueryParam("pageSize"))
	if pageSize < 1 {
		pageSize = 20
	}
	items, total, err := cc.customerService.List(c.Context(), page, pageSize)
	if err != nil {
		return nil, err
	}
	return dto.Ok(listCustomersResponse{Items: items, Total: total}, "success", http.StatusOK), nil
}

func (cc *CustomerController) Create(c fuego.ContextWithBody[dto.CreateCustomerRequest]) (*dto.Envelope[dto.CustomerPayload], error) {
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	data, err := cc.customerService.Create(c.Context(), body)
	if err != nil {
		return nil, err
	}
	c.SetStatus(http.StatusCreated)
	return dto.Ok(data, "Tạo khách hàng thành công", http.StatusCreated), nil
}

// GetByID returns the full customer record for the given {id} path param.
func (cc *CustomerController) GetByID(c fuego.ContextNoBody) (*dto.Envelope[dto.CustomerPayload], error) {
	id := c.PathParam("id")
	data, err := cc.customerService.GetByID(c.Context(), id)
	if err != nil {
		return nil, err
	}
	return dto.Ok(data, "success", http.StatusOK), nil
}

// Update updates a customer.
func (cc *CustomerController) Update(c fuego.ContextWithBody[dto.UpdateCustomerRequest]) (*dto.Envelope[dto.CustomerPayload], error) {
	id := c.PathParam("id")
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	data, err := cc.customerService.Update(c.Context(), id, body)
	if err != nil {
		return nil, err
	}
	return dto.Ok(data, constant.MsgCustomerUpdateSuccess, http.StatusOK), nil
}

// Delete soft-deletes a customer.
func (cc *CustomerController) Delete(c fuego.ContextNoBody) (*dto.Envelope[any], error) {
	id := c.PathParam("id")
	if err := cc.customerService.Delete(c.Context(), id); err != nil {
		return nil, err
	}
	return dto.Ok[any](nil, constant.MsgCustomerDeleteSuccess, http.StatusOK), nil
}

// Suggest returns customers for dropdown: ?q=...
func (cc *CustomerController) Suggest(c fuego.ContextNoBody) (*dto.Envelope[[]dto.CustomerPayload], error) {
	q := c.QueryParam("q")
	list, err := cc.customerService.Suggest(c.Context(), q)
	if err != nil {
		return nil, err
	}
	return dto.Ok(list, "success", http.StatusOK), nil
}
