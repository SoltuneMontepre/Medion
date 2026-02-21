// --- Quality Control (Kiểm tra chất lượng / KCS) ---

export type QCCheckStatus =
	| 'Pending'
	| 'InProgress'
	| 'Passed'
	| 'Failed'
	| 'ConditionalPass'

export type QCCheckType =
	| 'InProcess'
	| 'FinalProduct'
	| 'RawMaterial'
	| 'Stability'

export interface QCCheckItem {
	id: string
	testParameter: string
	specification: string
	result: string
	passed: boolean
	notes: string | null
}

export interface QCCheck {
	id: string
	checkNumber: string
	productionOrderId: string
	productionOrderNumber: string
	productId: string
	productCode: string
	productName: string
	lotNumber: string
	checkType: QCCheckType
	status: QCCheckStatus
	items: QCCheckItem[]
	conclusion: string | null
	notes: string | null
	checkedBy: string | null
	checkedAt: string | null
	approvedBy: string | null
	approvedAt: string | null
	createdAt: string
	updatedAt: string | null
}

export interface CreateQCCheckItemRequest {
	testParameter: string
	specification: string
}

export interface CreateQCCheckRequest {
	productionOrderId: string
	productId: string
	lotNumber: string
	checkType: QCCheckType
	items: CreateQCCheckItemRequest[]
	notes?: string
}
