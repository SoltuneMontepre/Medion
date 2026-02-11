/**
 * Shared API response envelope used by all services.
 * Matches backend ApiResult<T> (RFC 7807–style).
 */
export interface ApiResult<T> {
	isSuccess: boolean
	data: T | null
	message?: string
	statusCode: number
	errors?: Record<string, string[]>
}

export function success<T>(
	data: T | null,
	message?: string,
	statusCode = 200
): ApiResult<T> {
	return {
		isSuccess: true,
		data,
		message: message ?? 'Operation completed successfully',
		statusCode,
	}
}

export function failure<T>(
	message: string,
	statusCode = 400,
	errors?: Record<string, string[]>
): ApiResult<T> {
	return {
		isSuccess: false,
		data: null,
		message,
		statusCode,
		errors,
	}
}

function isApiResultShape<T>(value: unknown): value is ApiResult<T> {
	return (
		typeof value === 'object' &&
		value !== null &&
		'isSuccess' in value &&
		'statusCode' in value
	)
}

/**
 * Wraps a service call and returns ApiResult<T>.
 * - On 2xx: returns response.data (must be ApiResult<T> from backend).
 * - On 4xx/5xx: returns body if it's ApiResult-shaped, otherwise failure result.
 * - On network/other errors: returns failure result.
 */
export async function apiCall<T>(
	request: () => Promise<{ data: unknown; status: number }>
): Promise<ApiResult<T>> {
	try {
		const response = await request()
		const body = response.data

		if (isApiResultShape<T>(body)) return body

		return success(body as T, undefined, response.status)
	} catch (err: unknown) {
		if (err && typeof err === 'object' && 'response' in err) {
			const ax = err as { response?: { data?: unknown; status?: number } }
			const data = ax.response?.data
			const status = ax.response?.status ?? 500

			if (isApiResultShape<T>(data)) return data

			const message =
				data &&
				typeof data === 'object' &&
				'message' in data &&
				typeof (data as { message: unknown }).message === 'string'
					? (data as { message: string }).message
					: 'Request failed'
			return failure<T>(message, status)
		}
		return failure<T>(
			err instanceof Error ? err.message : 'An unexpected error occurred',
			0
		)
	}
}
