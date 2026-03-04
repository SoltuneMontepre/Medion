package dto

import (
	"github.com/google/uuid"
	"time"
)

// OrderItemPayload for create request.
type OrderItemPayload struct {
	ProductID uuid.UUID `json:"productId"`
	Quantity  int       `json:"quantity"`
}

// OrderItemDetail for order detail response (includes product info).
type OrderItemDetail struct {
	ProductID       uuid.UUID `json:"productId"`
	ProductCode     string    `json:"productCode"`
	ProductName     string    `json:"productName"`
	PackageSize     string    `json:"packageSize"`
	PackageUnit     string    `json:"packageUnit"`
	ProductType     string    `json:"productType"`
	PackagingType   string    `json:"packagingType"`
	Quantity        int       `json:"quantity"`
}

// CreateOrderRequest for POST /sale/orders (with digital sign / PIN).
type CreateOrderRequest struct {
	CustomerID uuid.UUID         `json:"customerId"`
	Items      []OrderItemPayload `json:"items"`
	PIN        string            `json:"pin"` // for digital sign verification
}

// OrderPayload returned in list.
type OrderPayload struct {
	ID            uuid.UUID `json:"id"`
	OrderNumber   string    `json:"orderNumber"`
	CustomerID    uuid.UUID `json:"customerId"`
	CustomerCode  string    `json:"customerCode"`
	CustomerName  string    `json:"customerName"`
	OrderDate     time.Time `json:"orderDate"`
	Status        string    `json:"status"`
}

// OrderDetailPayload returned in get by id (with items).
type OrderDetailPayload struct {
	OrderPayload
	Items []OrderItemDetail `json:"items"`
}

// CheckCustomerOrderTodayResponse: hasOrderToday, existingOrderID (if any), nextOrderNumber (if no order today).
type CheckCustomerOrderTodayResponse struct {
	HasOrderToday    bool      `json:"hasOrderToday"`
	ExistingOrderID  uuid.UUID `json:"existingOrderId,omitempty"`
	NextOrderNumber  string    `json:"nextOrderNumber,omitempty"`
}
