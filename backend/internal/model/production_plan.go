package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Production plan status: draft (nhân viên lập), submitted (gửi trưởng phòng), approved (duyệt).
const (
	ProductionPlanStatusDraft     = "draft"
	ProductionPlanStatusSubmitted = "submitted"
	ProductionPlanStatusApproved  = "approved"
)

// ProductionPlan is the daily production plan (Bảng kế hoạch sản xuất theo ngày).
// Created by planning staff after checking finished product inventory; sent to Head of Planning for approval.
type ProductionPlan struct {
	Base        `gorm:"embedded"`
	PlanDate    time.Time  `gorm:"type:date;not null;uniqueIndex:idx_production_plan_date"` // one plan per day
	Status      string     `gorm:"size:20;not null;default:draft"`
	ApprovedAt  *time.Time `gorm:"type:timestamp"`
	ApprovedBy  *uuid.UUID `gorm:"type:uuid"`

	Items []ProductionPlanItem `gorm:"foreignKey:ProductionPlanID"`
}

func (ProductionPlan) TableName() string {
	return "production_plans"
}

func (p *ProductionPlan) BeforeCreate(tx *gorm.DB) error {
	if p.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		p.ID = id
	}
	if p.Status == "" {
		p.Status = ProductionPlanStatusDraft
	}
	return nil
}
