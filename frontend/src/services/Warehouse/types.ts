// --- Warehouse Export Slip (Phiếu xuất kho thành phẩm) ---

export type ExportSlipStatus =
	| 'Draft'
	| 'PendingApproval'
	| 'Approved'
	| 'Exported'
	| 'Cancelled'

export interface ExportSlipItem {
	id: string
	productId: string
	productCode: string
	productName: string
	specification: string
	type: string
	packaging: string
	quantity: number
	lotNumber: string
	manufacturingDate: string
	expiryDate: string
}

export interface ExportSlip {
	id: string
	slipNumber: string
	orderId: string
	orderNumber: string
	customerId: string
	customerCode: string
	customerName: string
	customerAddress: string
	customerPhone: string
	status: ExportSlipStatus
	items: ExportSlipItem[]
	createdAt: string
	updatedAt: string | null
	createdBy: string | null
	approvedBy: string | null
	approvedAt: string | null
	exportedBy: string | null
	exportedAt: string | null
}

export interface CreateExportSlipItemRequest {
	productId: string
	quantity: number
	lotNumber: string
	manufacturingDate: string
	expiryDate: string
}

export interface CreateExportSlipRequest {
	orderId: string
	items: CreateExportSlipItemRequest[]
}

// --- Warehouse Receipt (Nhập kho thành phẩm) ---

export type ReceiptStatus = 'Draft' | 'Confirmed' | 'Cancelled'

export interface ReceiptItem {
	id: string
	productId: string
	productCode: string
	productName: string
	specification: string
	type: string
	packaging: string
	quantity: number
	lotNumber: string
	manufacturingDate: string
	expiryDate: string
}

export interface WarehouseReceipt {
	id: string
	receiptNumber: string
	productionOrderId: string
	productionOrderNumber: string
	status: ReceiptStatus
	items: ReceiptItem[]
	createdAt: string
	updatedAt: string | null
	createdBy: string | null
	confirmedBy: string | null
	confirmedAt: string | null
}

// --- Inventory (Tồn kho) ---

export interface InventoryItem {
	id: string
	productId: string
	productCode: string
	productName: string
	specification: string
	type: string
	packaging: string
	lotNumber: string
	quantity: number
	manufacturingDate: string
	expiryDate: string
	warehouseLocation: string
}
