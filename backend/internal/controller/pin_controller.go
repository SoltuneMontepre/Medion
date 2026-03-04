package controller

import (
	"net/http"

	"backend/internal/constant"
	"backend/internal/dto"
	"backend/internal/middleware"
	"backend/internal/service"

	"github.com/go-fuego/fuego"
)

type PINController struct {
	pinService *service.PINService
}

func NewPINController(pinService *service.PINService) *PINController {
	return &PINController{pinService: pinService}
}

func (p *PINController) Status(c fuego.ContextNoBody) (*dto.Envelope[dto.PINStatusPayload], error) {
	token, ok := middleware.GetAccessTokenFromContext(c.Context())
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1011, Message: "access token is missing"}
	}
	status, err := p.pinService.Status(c.Context(), token)
	if err != nil {
		return nil, err
	}
	return dto.Ok(status, "success", http.StatusOK), nil
}

func (p *PINController) Set(c fuego.ContextWithBody[dto.SetPINRequest]) (*dto.Envelope[dto.PINStatusPayload], error) {
	token, ok := middleware.GetAccessTokenFromContext(c.Context())
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1011, Message: "access token is missing"}
	}
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	if err := p.pinService.SetPIN(c.Context(), token, body.PIN); err != nil {
		return nil, err
	}
	return dto.Ok(dto.PINStatusPayload{HasPIN: true}, constant.MsgPINSetSuccess, http.StatusCreated), nil
}

func (p *PINController) Change(c fuego.ContextWithBody[dto.ChangePINRequest]) (*dto.Envelope[dto.PINStatusPayload], error) {
	token, ok := middleware.GetAccessTokenFromContext(c.Context())
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1011, Message: "access token is missing"}
	}
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	if err := p.pinService.ChangePIN(c.Context(), token, body.OldPIN, body.NewPIN); err != nil {
		return nil, err
	}
	return dto.Ok(dto.PINStatusPayload{HasPIN: true}, constant.MsgPINChangeSuccess, http.StatusOK), nil
}

func (p *PINController) Verify(c fuego.ContextWithBody[dto.VerifyPINRequest]) (*dto.Envelope[dto.VerifyPINPayload], error) {
	token, ok := middleware.GetAccessTokenFromContext(c.Context())
	if !ok {
		return nil, &dto.AppError{HTTPStatus: http.StatusUnauthorized, Code: 1011, Message: "access token is missing"}
	}
	body, err := c.Body()
	if err != nil {
		return nil, err
	}
	result, err := p.pinService.VerifyByToken(c.Context(), token, body.PIN)
	if err != nil {
		return nil, err
	}
	return dto.Ok(result, "success", http.StatusOK), nil
}
