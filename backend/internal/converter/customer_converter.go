package converter

import (
	"backend/internal/dto"
	"backend/internal/model"
)

func (c *Converter) CustomerToPayload(customer model.Customer) dto.CustomerPayload {
	return dto.CustomerPayload{
		ID:            customer.ID,
		Code:          customer.Code,
		Name:          customer.Name,
		Address:       customer.Address,
		Phone:         customer.Phone,
		ContactPerson: customer.ContactPerson,
	}
}

func (c *Converter) CustomersToPayloads(customers []model.Customer) []dto.CustomerPayload {
	payloads := make([]dto.CustomerPayload, len(customers))
	for i, customer := range customers {
		payloads[i] = c.CustomerToPayload(customer)
	}
	return payloads
}
