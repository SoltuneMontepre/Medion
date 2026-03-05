package converter

import (
	"backend/internal/dto"
	"backend/internal/model"
)

func (c *Converter) DepartmentToPayload(d model.Department) dto.DepartmentPayload {
	payload := dto.DepartmentPayload{
		ID:          d.ID,
		CompanyID:   d.CompanyID,
		Code:        d.Code,
		Name:        d.Name,
		Description: d.Description,
	}
	if d.Company != nil {
		payload.CompanyName = d.Company.Name
	}
	return payload
}

func (c *Converter) DepartmentsToPayloads(departments []model.Department) []dto.DepartmentPayload {
	payloads := make([]dto.DepartmentPayload, len(departments))
	for i, d := range departments {
		payloads[i] = c.DepartmentToPayload(d)
	}
	return payloads
}

func (c *Converter) CompanyToPayload(company model.Company) dto.CompanyPayload {
	return dto.CompanyPayload{
		ID:     company.ID,
		Code:   company.Code,
		Name:   company.Name,
		Active: company.Active,
	}
}

func (c *Converter) CompaniesToPayloads(companies []model.Company) []dto.CompanyPayload {
	payloads := make([]dto.CompanyPayload, len(companies))
	for i, company := range companies {
		payloads[i] = c.CompanyToPayload(company)
	}
	return payloads
}
