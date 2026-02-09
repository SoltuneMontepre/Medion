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
