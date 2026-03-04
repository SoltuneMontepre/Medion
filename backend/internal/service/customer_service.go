package service

import (
	"context"
	"net/http"
	"regexp"
	"strings"

	"backend/internal/constant"
	"backend/internal/converter"
	"backend/internal/dto"
	"backend/internal/model"
	"backend/internal/repository"
)

// Vietnamese mobile: 10 digits starting with 0 (e.g. 0901234567).
var phoneRegex = regexp.MustCompile(`^0[0-9]{9}$`)

type CustomerService struct {
	customers *repository.CustomerRepository
	converter *converter.Converter
}

func NewCustomerService(customers *repository.CustomerRepository, conv *converter.Converter) *CustomerService {
	return &CustomerService{customers: customers, converter: conv}
}

func (s *CustomerService) List(ctx context.Context, page, pageSize int) ([]dto.CustomerPayload, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	offset := (page - 1) * pageSize
	list, err := s.customers.FindAll(ctx, pageSize, offset)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2501, Message: "failed to list customers", Err: err}
	}
	total, err := s.customers.Count(ctx)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2502, Message: "failed to count customers", Err: err}
	}
	return s.converter.CustomersToPayloads(list), total, nil
}

func (s *CustomerService) Create(ctx context.Context, req dto.CreateCustomerRequest) (dto.CustomerPayload, error) {
	name := strings.TrimSpace(req.Name)
	address := strings.TrimSpace(req.Address)
	phone := strings.TrimSpace(req.Phone)

	if name == "" {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2001, Message: constant.MsgCustomerNameRequired}
	}
	if address == "" {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2002, Message: constant.MsgCustomerAddressRequired}
	}
	if phone == "" {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2003, Message: constant.MsgCustomerPhoneRequired}
	}
	if !phoneRegex.MatchString(phone) {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2004, Message: constant.MsgCustomerPhoneInvalid}
	}

	exists, err := s.customers.ExistsByPhone(ctx, phone)
	if err != nil {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2503, Message: "failed to check phone", Err: err}
	}
	if exists {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusConflict, Code: 2005, Message: constant.MsgCustomerPhoneExists}
	}

	// CreatedBy/UpdatedBy: zero value (uuid.Nil) until auth user is set from context
	customer := model.Customer{
		Name:    name,
		Address: address,
		Phone:   phone,
	}
	if err := s.customers.Create(ctx, &customer); err != nil {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2504, Message: "failed to create customer", Err: err}
	}
	return s.converter.CustomerToPayload(customer), nil
}

// Suggest returns customers matching query (code, name, or phone) for dropdown. Limit 20.
func (s *CustomerService) Suggest(ctx context.Context, query string) ([]dto.CustomerPayload, error) {
	query = strings.TrimSpace(query)
	if len(query) < 1 {
		return []dto.CustomerPayload{}, nil
	}
	list, err := s.customers.SearchByCodeNamePhone(ctx, query, 20)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2505, Message: "failed to search customers", Err: err}
	}
	return s.converter.CustomersToPayloads(list), nil
}
