/** Customer as returned by the Sale API (IDs are GUID strings). */
export interface Customer {
	id: string
	code: string
	firstName: string
	lastName: string
	address: string
	phoneNumber: string
	createdAt: string
	updatedAt: string | null
	createdBy: string | null
	updatedBy: string | null
}

/** Request body for creating a new customer. */
export interface CreateCustomerRequest {
	firstName: string
	lastName: string
	address: string
	phoneNumber: string
}

/** Request body for updating an existing customer. */
export interface UpdateCustomerRequest {
	firstName: string
	lastName: string
	address: string
	phoneNumber: string
}

// --- Order ---

export type OrderStatus = 'Draft' | 'Signed'

/** Order item as returned by the Sale API. */
export interface OrderItem {
	id: string
	productId: string
	productCode: string
	productName: string
	quantity: number
}

/** Full order as returned by the Sale API. */
export interface Order {
	id: string
	orderNumber: string
	customerId: string
	orderDate: string
	status: OrderStatus
	salesStaffId: string
	signedAt: string | null
	signedBy: string | null
	signaturePublicKey: string | null
	items: OrderItem[]
}

/** Order summary (e.g. today's order for a customer). */
export interface OrderSummary {
	id: string
	orderNumber: string
	orderDate: string
	status: OrderStatus
	customerId: string
}

/** Request body for creating an order item. */
export interface CreateOrderItemRequest {
	productId: string
	quantity: number
}

/** Request body for creating an order. */
export interface CreateOrderRequest {
	customerId: string
	salesStaffId: string
	pin: string
	items: CreateOrderItemRequest[]
}

// --- Product ---

/** Product list item as returned by the Sale API. */
export interface Product {
	id: string
	code: string
	name: string
}

/** Product detail as returned by the Sale API. */
export interface ProductDetail {
	id: string
	code: string
	name: string
	specification: string
	type: string
	packaging: string
	createdAt: string
	updatedAt: string | null
	createdBy: string | null
	updatedBy: string | null
}

/** Request body for creating a product. */
export interface CreateProductRequest {
	code: string
	name: string
	specification: string
	type: string
	packaging: string
}

/** Request body for updating a product. */
export interface UpdateProductRequest {
	code: string
	name: string
	specification: string
	type: string
	packaging: string
}
