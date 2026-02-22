import { useMutation } from '@tanstack/react-query'
import { apiCall } from '../apiResult'
import type { ApiResult } from '../apiResult'
import axiosInstance from '../axios'
import type {
	SetupTransactionPinRequest,
	SetupTransactionPinResponse,
} from './types'

const SECURITY_BASE = 'api/security/api/v1/security/transaction-pin'

/** Set up or change the current user's transaction PIN (for signing orders). */
export function useSetupTransactionPin() {
	return useMutation({
		mutationFn: (body: SetupTransactionPinRequest) =>
			apiCall(() =>
				axiosInstance.post<ApiResult<SetupTransactionPinResponse>>(
					`${SECURITY_BASE}/setup`,
					body
				)
			),
	})
}
