package controller

import (
	"net/http"
	"strconv"

	"backend/internal/constant"
	"backend/internal/dto"
	"backend/internal/service"

	"github.com/go-fuego/fuego"
)

type DepartmentController struct {
	departmentService *service.DepartmentService
}

func NewDepartmentController(departmentService *service.DepartmentService) *DepartmentController {
	return &DepartmentController{departmentService: departmentService}
}

type listDepartmentsResponse struct {
	Items []dto.DepartmentPayload `json:"items"`
	Total int64                   `json:"total"`
}

func (dc *DepartmentController) List(c fuego.ContextNoBody) (*dto.Envelope[listDepartmentsResponse], error) {
	companyID := c.QueryParam("companyId")
	page, _ := strconv.Atoi(c.QueryParam("page"))
	if page < 1 {
		page = 1
	}
	pageSize, _ := strconv.Atoi(c.QueryParam("pageSize"))
	if pageSize < 1 {
		pageSize = 20
	}
	items, total, err := dc.departmentService.List(c.Context(), companyID, page, pageSize)
	if err != nil {
		return nil, err
	}
	return dto.Ok(listDepartmentsResponse{Items: items, Total: total}, "success", http.StatusOK), nil
}

func (dc *DepartmentController) Create(c fuego.ContextWithBody[dto.CreateDepartmentRequest]) (*dto.Envelope[dto.DepartmentPayload], error) {
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	data, err := dc.departmentService.Create(c.Context(), body)
	if err != nil {
		return nil, err
	}
	c.SetStatus(http.StatusCreated)
	return dto.Ok(data, "Tạo phòng ban thành công", http.StatusCreated), nil
}

func (dc *DepartmentController) GetByID(c fuego.ContextNoBody) (*dto.Envelope[dto.DepartmentPayload], error) {
	id := c.PathParam("id")
	data, err := dc.departmentService.GetByID(c.Context(), id)
	if err != nil {
		return nil, err
	}
	return dto.Ok(data, "success", http.StatusOK), nil
}

func (dc *DepartmentController) Update(c fuego.ContextWithBody[dto.UpdateDepartmentRequest]) (*dto.Envelope[dto.DepartmentPayload], error) {
	id := c.PathParam("id")
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	data, err := dc.departmentService.Update(c.Context(), id, body)
	if err != nil {
		return nil, err
	}
	return dto.Ok(data, constant.MsgDepartmentUpdateSuccess, http.StatusOK), nil
}

func (dc *DepartmentController) Delete(c fuego.ContextNoBody) (*dto.Envelope[any], error) {
	id := c.PathParam("id")
	if err := dc.departmentService.Delete(c.Context(), id); err != nil {
		return nil, err
	}
	return dto.Ok[any](nil, constant.MsgDepartmentDeleteSuccess, http.StatusOK), nil
}

func (dc *DepartmentController) Suggest(c fuego.ContextNoBody) (*dto.Envelope[[]dto.DepartmentPayload], error) {
	companyID := c.QueryParam("companyId")
	q := c.QueryParam("q")
	list, err := dc.departmentService.Suggest(c.Context(), companyID, q)
	if err != nil {
		return nil, err
	}
	return dto.Ok(list, "success", http.StatusOK), nil
}
