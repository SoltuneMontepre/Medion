/** Request body for setting up transaction PIN (Security API). */
export interface SetupTransactionPinRequest {
	plainPin: string
}

/** Success response from transaction PIN setup. */
export interface SetupTransactionPinResponse {
	message: string
	userId: string
}
