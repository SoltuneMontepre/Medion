package service

import (
	"context"
	"errors"
	"net/http"
	"strings"

	"backend/internal/constant"
	"backend/internal/converter"
	"backend/internal/dto"
	"backend/internal/model"
	"backend/internal/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type DepartmentService struct {
	departments *repository.DepartmentRepository
	companies   *repository.CompanyRepository
	converter   *converter.Converter
	companySvc  *CompanyService
}

func NewDepartmentService(
	departments *repository.DepartmentRepository,
	companies *repository.CompanyRepository,
	conv *converter.Converter,
	companySvc *CompanyService,
) *DepartmentService {
	return &DepartmentService{
		departments: departments,
		companies:   companies,
		converter:   conv,
		companySvc:  companySvc,
	}
}

func (s *DepartmentService) List(ctx context.Context, companyID string, page, pageSize int) ([]dto.DepartmentPayload, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	offset := (page - 1) * pageSize

	var cID *uuid.UUID
	if companyID != "" {
		parsed, err := uuid.Parse(companyID)
		if err != nil {
			return nil, 0, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 3001, Message: constant.MsgDepartmentCompanyRequired}
		}
		cID = &parsed
	}

	list, err := s.departments.FindAll(ctx, cID, pageSize, offset)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 3501, Message: "failed to list departments", Err: err}
	}
	total, err := s.departments.Count(ctx, cID)
	if err != nil {
		return nil, 0, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 3502, Message: "failed to count departments", Err: err}
	}
	return s.converter.DepartmentsToPayloads(list), total, nil
}

func (s *DepartmentService) GetByID(ctx context.Context, id string) (dto.DepartmentPayload, error) {
	d, err := s.departments.FindByIDWithCompany(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 3002, Message: constant.MsgDepartmentNotFound}
		}
		return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 3503, Message: "failed to get department", Err: err}
	}
	return s.converter.DepartmentToPayload(*d), nil
}

func (s *DepartmentService) Create(ctx context.Context, req dto.CreateDepartmentRequest) (dto.DepartmentPayload, error) {
	companyID := strings.TrimSpace(req.CompanyID)
	code := strings.TrimSpace(req.Code)
	name := strings.TrimSpace(req.Name)
	description := strings.TrimSpace(req.Description)

	if companyID == "" {
		return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 3003, Message: constant.MsgDepartmentCompanyRequired}
	}
	cUUID, err := uuid.Parse(companyID)
	if err != nil {
		return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 3004, Message: constant.MsgCompanyNotFound}
	}
	exists, err := s.companySvc.Exists(ctx, companyID)
	if err != nil {
		return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 3504, Message: "failed to check company", Err: err}
	}
	if !exists {
		return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 3005, Message: constant.MsgCompanyNotFound}
	}
	if code == "" {
		return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 3006, Message: constant.MsgDepartmentCodeRequired}
	}
	if name == "" {
		return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 3007, Message: constant.MsgDepartmentNameRequired}
	}

	existsCode, err := s.departments.ExistsByCompanyIDAndCode(ctx, cUUID, code)
	if err != nil {
		return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 3505, Message: "failed to check department code", Err: err}
	}
	if existsCode {
		return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusConflict, Code: 3008, Message: constant.MsgDepartmentCodeExists}
	}

	department := model.Department{
		CompanyID:   cUUID,
		Code:        code,
		Name:        name,
		Description: description,
	}
	if err := s.departments.Create(ctx, &department); err != nil {
		return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 3506, Message: "failed to create department", Err: err}
	}
	// Reload with Company for response
	d, _ := s.departments.FindByIDWithCompany(ctx, department.ID.String())
	if d != nil {
		return s.converter.DepartmentToPayload(*d), nil
	}
	return s.converter.DepartmentToPayload(department), nil
}

func (s *DepartmentService) Update(ctx context.Context, id string, req dto.UpdateDepartmentRequest) (dto.DepartmentPayload, error) {
	code := strings.TrimSpace(req.Code)
	name := strings.TrimSpace(req.Name)
	description := strings.TrimSpace(req.Description)

	if code == "" {
		return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 3006, Message: constant.MsgDepartmentCodeRequired}
	}
	if name == "" {
		return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 3007, Message: constant.MsgDepartmentNameRequired}
	}

	existing, err := s.departments.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 3002, Message: constant.MsgDepartmentNotFound}
		}
		return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 3503, Message: "failed to get department", Err: err}
	}

	if existing.Code != code {
		existsCode, err := s.departments.ExistsByCompanyIDAndCodeExcludingID(ctx, existing.CompanyID, code, id)
		if err != nil {
			return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 3505, Message: "failed to check department code", Err: err}
		}
		if existsCode {
			return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusConflict, Code: 3008, Message: constant.MsgDepartmentCodeExists}
		}
	}

	existing.Code = code
	existing.Name = name
	existing.Description = description
	if err := s.departments.Update(ctx, existing); err != nil {
		return dto.DepartmentPayload{}, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 3507, Message: "failed to update department", Err: err}
	}
	d, _ := s.departments.FindByIDWithCompany(ctx, id)
	if d != nil {
		return s.converter.DepartmentToPayload(*d), nil
	}
	return s.converter.DepartmentToPayload(*existing), nil
}

func (s *DepartmentService) Delete(ctx context.Context, id string) error {
	_, err := s.departments.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return &dto.AppError{HTTPStatus: http.StatusNotFound, Code: 3002, Message: constant.MsgDepartmentNotFound}
		}
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 3503, Message: "failed to get department", Err: err}
	}
	if err := s.departments.Delete(ctx, id); err != nil {
		return &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 3508, Message: "failed to delete department", Err: err}
	}
	return nil
}

// Suggest returns departments for dropdown; optional companyID and query q.
func (s *DepartmentService) Suggest(ctx context.Context, companyID string, q string) ([]dto.DepartmentPayload, error) {
	q = strings.TrimSpace(q)
	if companyID != "" {
		cUUID, err := uuid.Parse(companyID)
		if err != nil {
			return nil, &dto.AppError{HTTPStatus: http.StatusBadRequest, Code: 3004, Message: constant.MsgCompanyNotFound}
		}
		list, err := s.departments.FindByCompanyID(ctx, cUUID)
		if err != nil {
			return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 3501, Message: "failed to list departments", Err: err}
		}
		if q != "" {
			filtered := make([]model.Department, 0)
			lower := strings.ToLower(q)
			for _, d := range list {
				if strings.Contains(strings.ToLower(d.Code), lower) || strings.Contains(strings.ToLower(d.Name), lower) {
					filtered = append(filtered, d)
				}
			}
			list = filtered
		}
		return s.converter.DepartmentsToPayloads(list), nil
	}
	// No company filter: list all with optional query (simple filter)
	var cID *uuid.UUID
	list, err := s.departments.FindAll(ctx, cID, 50, 0)
	if err != nil {
		return nil, &dto.AppError{HTTPStatus: http.StatusInternalServerError, Code: 3501, Message: "failed to list departments", Err: err}
	}
	if q != "" {
		filtered := make([]model.Department, 0)
		lower := strings.ToLower(q)
		for _, d := range list {
			if strings.Contains(strings.ToLower(d.Code), lower) || strings.Contains(strings.ToLower(d.Name), lower) {
				filtered = append(filtered, d)
			}
		}
		list = filtered
	}
	return s.converter.DepartmentsToPayloads(list), nil
}
