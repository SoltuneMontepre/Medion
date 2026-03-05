package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Finished product dispatch (Phiếu xuất kho Thành phẩm) status.
const (
	FinishedProductDispatchStatusDraft           = "draft"
	FinishedProductDispatchStatusPendingApproval = "pending_approval"
	FinishedProductDispatchStatusApproved        = "approved"
	FinishedProductDispatchStatusRevisionRequested = "revision_requested"
)

// FinishedProductDispatch is the header: customer, order number, approval workflow.
// Created by Kế toán kho; approved by Quản lý kho. One slip per customer order.
type FinishedProductDispatch struct {
	Base            `gorm:"embedded"`
	CustomerID      uuid.UUID  `gorm:"type:uuid;not null;index:idx_dispatch_customer"`
	OrderNumber     string     `gorm:"size:64;not null;index:idx_dispatch_order"`
	Address         string     `gorm:"size:512;not null"`
	Phone           string     `gorm:"size:20;not null"`
	Status          string     `gorm:"size:32;not null;default:draft"`
	RejectionReason string     `gorm:"size:1024"` // yêu cầu sửa from Quản lý kho
	ApprovedAt      *time.Time `gorm:"type:timestamp"`
	ApprovedBy      *uuid.UUID `gorm:"type:uuid"`

	Customer *Customer                    `gorm:"foreignKey:CustomerID"`
	Items    []FinishedProductDispatchLine `gorm:"foreignKey:DispatchID"`
}

func (FinishedProductDispatch) TableName() string {
	return "finished_product_dispatches"
}

func (d *FinishedProductDispatch) BeforeCreate(tx *gorm.DB) error {
	if d.ID == uuid.Nil {
		id, err := uuid.NewV7()
		if err != nil {
			return err
		}
		d.ID = id
	}
	if d.Status == "" {
		d.Status = FinishedProductDispatchStatusDraft
	}
	return nil
}
