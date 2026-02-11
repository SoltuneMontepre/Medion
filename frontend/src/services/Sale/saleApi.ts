import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { apiCall } from '../apiResult'
import type { ApiResult } from '../apiResult'
import axiosInstance from '../axios'
import type {
	CreateCustomerRequest,
	Customer,
	UpdateCustomerRequest,
} from './types'

const SALE_BASE = '/api/sale'
const CUSTOMER_BASE = `${SALE_BASE}/customer`

export const saleQueryKeys = {
	allCustomers: ['sale', 'customers'] as const,
	customer: (customerId: string) => ['sale', 'customer', customerId] as const,
}

/** Get all customers. */
export function useGetAllCustomers(options?: { enabled?: boolean }) {
	return useQuery({
		queryKey: saleQueryKeys.allCustomers,
		queryFn: () =>
			apiCall(() => axiosInstance.get<ApiResult<Customer[]>>(CUSTOMER_BASE)),
		enabled: options?.enabled ?? true,
	})
}

/** Get customer by id. */
export function useGetCustomerById(
	customerId: string,
	options?: { enabled?: boolean }
) {
	return useQuery({
		queryKey: saleQueryKeys.customer(customerId),
		queryFn: () =>
			apiCall(() =>
				axiosInstance.get<ApiResult<Customer>>(`${CUSTOMER_BASE}/${customerId}`)
			),
		enabled: (options?.enabled ?? true) && !!customerId,
	})
}

/** Create a new customer. */
export function useCreateCustomer() {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: (body: CreateCustomerRequest) =>
			apiCall(() =>
				axiosInstance.post<ApiResult<Customer>>(CUSTOMER_BASE, body)
			),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: saleQueryKeys.allCustomers })
		},
	})
}

/** Update an existing customer. */
export function useUpdateCustomer() {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: ({ id, body }: { id: string; body: UpdateCustomerRequest }) =>
			apiCall(() =>
				axiosInstance.put<ApiResult<Customer>>(`${CUSTOMER_BASE}/${id}`, body)
			),
		onSuccess: (_, variables) => {
			queryClient.invalidateQueries({
				queryKey: saleQueryKeys.customer(variables.id),
			})
			queryClient.invalidateQueries({ queryKey: saleQueryKeys.allCustomers })
		},
	})
}

/** Delete a customer (soft delete). */
export function useDeleteCustomer() {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: (customerId: string) =>
			apiCall(() =>
				axiosInstance.delete<ApiResult<boolean>>(
					`${CUSTOMER_BASE}/${customerId}`
				)
			),
		onSuccess: (_, customerId) => {
			queryClient.invalidateQueries({
				queryKey: saleQueryKeys.customer(customerId),
			})
			queryClient.invalidateQueries({ queryKey: saleQueryKeys.allCustomers })
		},
	})
}
