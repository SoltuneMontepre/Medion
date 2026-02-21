// --- Delivery (Giao hàng) ---

export type DeliveryStatus =
	| 'Pending'
	| 'InTransit'
	| 'Delivered'
	| 'PartialDelivery'
	| 'Returned'
	| 'Cancelled'

export interface Delivery {
	id: string
	deliveryNumber: string
	exportSlipId: string
	exportSlipNumber: string
	orderId: string
	orderNumber: string
	customerId: string
	customerCode: string
	customerName: string
	customerAddress: string
	customerPhone: string
	status: DeliveryStatus
	deliveryDate: string | null
	deliveredAt: string | null
	deliveredBy: string | null
	notes: string | null
	createdAt: string
	updatedAt: string | null
}
