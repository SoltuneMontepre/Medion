// --- Production Plan (Bảng kế hoạch sản xuất) ---

export type ProductionPlanStatus =
	| 'Draft'
	| 'Approved'
	| 'InProgress'
	| 'Completed'
	| 'Cancelled'

export interface ProductionPlanItem {
	id: string
	productId: string
	productCode: string
	productName: string
	specification: string
	type: string
	packaging: string
	quantity: number
}

export interface ProductionPlan {
	id: string
	planNumber: string
	planDate: string
	status: ProductionPlanStatus
	notes: string | null
	items: ProductionPlanItem[]
	createdAt: string
	updatedAt: string | null
	createdBy: string | null
	approvedBy: string | null
	approvedAt: string | null
}

export interface CreateProductionPlanItemRequest {
	productId: string
	quantity: number
}

export interface CreateProductionPlanRequest {
	planDate: string
	notes?: string
	items: CreateProductionPlanItemRequest[]
}

// --- Production Order / Lệnh SX kiêm Phiếu Xuất Kho Vật Tư ---

export type ProductionOrderStatus =
	| 'Pending'
	| 'InProgress'
	| 'QCPending'
	| 'QCPassed'
	| 'QCFailed'
	| 'Completed'
	| 'Cancelled'

/** Raw material line in a production order (BOM row). */
export interface RawMaterialItem {
	id: string
	materialId: string
	materialCode: string
	materialName: string
	unit: string
	ratioPercent: number
	formulaPerUnit: number
	exportQuantity: number
	varianceQuantity: number | null
	notes: string | null
}

/** Product being manufactured in this production order. */
export interface ProductionOrderProduct {
	productId: string
	productCode: string
	productName: string
	productType: string
	specification1: string
	specification2: string | null
	quantitySpec1: number
	quantitySpec2: number
	batchSize: number
	batchUnit: string
}

export interface ProductionOrder {
	id: string
	orderNumber: string
	productionPlanId: string
	productionPlanNumber: string
	status: ProductionOrderStatus
	product: ProductionOrderProduct
	lotNumber: string
	manufacturingDate: string
	expiryDate: string
	rawMaterials: RawMaterialItem[]
	rawMaterialTotal: number
	ph: string | null
	notes: string | null
	createdAt: string
	updatedAt: string | null
	createdBy: string | null
	approvedBy: string | null
	approvedAt: string | null
}

export interface CreateRawMaterialItemRequest {
	materialId: string
	ratioPercent: number
	formulaPerUnit: number
	exportQuantity: number
	varianceQuantity?: number
	notes?: string
}

export interface CreateProductionOrderRequest {
	productionPlanId: string
	productId: string
	lotNumber: string
	manufacturingDate: string
	expiryDate: string
	batchSize: number
	batchUnit: string
	specification1: string
	quantitySpec1: number
	specification2?: string
	quantitySpec2?: number
	ph?: string
	notes?: string
	rawMaterials: CreateRawMaterialItemRequest[]
}
