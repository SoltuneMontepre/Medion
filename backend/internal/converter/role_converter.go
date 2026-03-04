package converter

import (
	"backend/internal/dto"
	"backend/internal/model"
)

func (c *Converter) RoleToPayload(r model.Role) dto.RolePayload {
	payload := dto.RolePayload{
		ID:          r.ID,
		Code:        r.Code,
		Name:        r.Name,
		Description: r.Description,
		ParentRoleID: r.ParentRoleID,
	}
	if r.ParentRole != nil {
		payload.ParentCode = r.ParentRole.Code
	}
	return payload
}

func (c *Converter) RolesToPayloads(roles []model.Role) []dto.RolePayload {
	payloads := make([]dto.RolePayload, len(roles))
	for i, r := range roles {
		payloads[i] = c.RoleToPayload(r)
	}
	return payloads
}
