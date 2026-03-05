package controller

import (
	"net/http"

	"backend/internal/dto"
	"backend/internal/service"

	"github.com/go-fuego/fuego"
)

type CompanyController struct {
	companyService *service.CompanyService
}

func NewCompanyController(companyService *service.CompanyService) *CompanyController {
	return &CompanyController{companyService: companyService}
}

func (cc *CompanyController) List(c fuego.ContextNoBody) (*dto.Envelope[[]dto.CompanyPayload], error) {
	list, err := cc.companyService.List(c.Context())
	if err != nil {
		return nil, err
	}
	return dto.Ok(list, "success", http.StatusOK), nil
}
