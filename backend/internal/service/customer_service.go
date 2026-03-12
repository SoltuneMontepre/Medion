package service

import (
	"context"
	"errors"
	"net/http"
	"regexp"
	"strings"

	"backend/internal/constant"
	"backend/internal/converter"
	"backend/internal/dto"
	"backend/internal/model"
	"backend/internal/repository"

	"gorm.io/gorm"
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
	code := strings.TrimSpace(req.Code)
	name := strings.TrimSpace(req.Name)
	address := strings.TrimSpace(req.Address)
	phone := strings.TrimSpace(req.Phone)
	contactPerson := strings.TrimSpace(req.ContactPerson)
	if len(contactPerson) > 128 {
		contactPerson = contactPerson[:128]
	}

	if code == "" {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2000, Message: constant.MsgCustomerCodeRequired}
	}
	if len(code) > 32 {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2012, Message: constant.MsgCustomerCodeTooLong}
	}
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

	existsCode, err := s.customers.ExistsByCode(ctx, code)
	if err != nil {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2503, Message: "failed to check code", Err: err}
	}
	if existsCode {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusConflict, Code: 2011, Message: constant.MsgCustomerCodeExists}
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
		Code:          code,
		Name:          name,
		Address:       address,
		Phone:         phone,
		ContactPerson: contactPerson,
	}
	if err := s.customers.Create(ctx, &customer); err != nil {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2504, Message: "failed to create customer", Err: err}
	}
	return s.converter.CustomerToPayload(customer), nil
}

// GetByID returns the full customer record for a given UUID string.
func (s *CustomerService) GetByID(ctx context.Context, id string) (dto.CustomerPayload, error) {
	customer, err := s.customers.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2006, Message: constant.MsgCustomerNotFound}
		}
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2506, Message: "failed to get customer", Err: err}
	}
	return s.converter.CustomerToPayload(*customer), nil
}

// Update updates a customer. Validates phone uniqueness when phone changes.
func (s *CustomerService) Update(ctx context.Context, id string, req dto.UpdateCustomerRequest) (dto.CustomerPayload, error) {
	name := strings.TrimSpace(req.Name)
	address := strings.TrimSpace(req.Address)
	phone := strings.TrimSpace(req.Phone)
	contactPerson := strings.TrimSpace(req.ContactPerson)
	if len(contactPerson) > 128 {
		contactPerson = contactPerson[:128]
	}

	if name == "" {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2007, Message: constant.MsgCustomerNameRequired}
	}
	if address == "" {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2008, Message: constant.MsgCustomerAddressRequired}
	}
	if phone == "" {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2009, Message: constant.MsgCustomerPhoneRequired}
	}
	if !phoneRegex.MatchString(phone) {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 2010, Message: constant.MsgCustomerPhoneInvalid}
	}

	existing, err := s.customers.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2006, Message: constant.MsgCustomerNotFound}
		}
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2506, Message: "failed to get customer", Err: err}
	}

	if existing.Phone != phone {
		exists, err := s.customers.ExistsByPhoneExcludingID(ctx, phone, id)
		if err != nil {
			return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2507, Message: "failed to check phone", Err: err}
		}
		if exists {
			return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusConflict, Code: 2005, Message: constant.MsgCustomerPhoneExists}
		}
	}

	existing.Name = name
	existing.Address = address
	existing.Phone = phone
	existing.ContactPerson = contactPerson
	if err := s.customers.Update(ctx, existing); err != nil {
		return dto.CustomerPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2508, Message: "failed to update customer", Err: err}
	}
	return s.converter.CustomerToPayload(*existing), nil
}

// Delete soft-deletes a customer.
func (s *CustomerService) Delete(ctx context.Context, id string) error {
	_, err := s.customers.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 2006, Message: constant.MsgCustomerNotFound}
		}
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2509, Message: "failed to get customer", Err: err}
	}
	if err := s.customers.Delete(ctx, id); err != nil {
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 2510, Message: "failed to delete customer", Err: err}
	}
	return nil
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
