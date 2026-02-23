import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { apiCall } from '../apiResult'
import type { ApiResult } from '../apiResult'
import axiosInstance from '../axios'
import type {
	CreateCustomerRequest,
	CreateOrderRequest,
	CreateProductRequest,
	Customer,
	DailyOrderSummaryItem,
	Order,
	OrderSummary,
	Product,
	ProductDetail,
	UpdateCustomerRequest,
	UpdateOrderRequest,
	UpdateProductRequest,
} from './types'

const SALE_BASE = '/api/sale'
const CUSTOMER_BASE = `${SALE_BASE}/customers`
const ORDER_BASE = `${SALE_BASE}/orders`
const PRODUCT_BASE = `${SALE_BASE}/products`

export const saleQueryKeys = {
	allCustomers: ['sale', 'customers'] as const,
	customer: (customerId: string) => ['sale', 'customer', customerId] as const,
	customerSearch: (term: string, limit?: number) =>
		['sale', 'customers', 'search', term, limit] as const,
	todayOrderByCustomer: (customerId: string) =>
		['sale', 'orders', 'customer', customerId, 'today'] as const,
	order: (orderId: string) => ['sale', 'orders', orderId] as const,
	dailyOrderSummary: (date: string | undefined) =>
		['sale', 'orders', 'daily-summary', date] as const,
	allProducts: ['sale', 'products'] as const,
	product: (productId: string) => ['sale', 'product', productId] as const,
	productSearch: (term: string, limit?: number) =>
		['sale', 'products', 'search', term, limit] as const,
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

/** Search customers by code, name, or phone (Sale Admin). */
export function useSearchCustomers(
	params: { term: string; limit?: number },
	options?: { enabled?: boolean }
) {
	const { term, limit } = params
	const effectiveLimit = limit && limit > 0 && limit <= 50 ? limit : 20
	return useQuery({
		queryKey: saleQueryKeys.customerSearch(term, effectiveLimit),
		queryFn: () =>
			apiCall(() =>
				axiosInstance.get<ApiResult<Customer[]>>(`${CUSTOMER_BASE}/search`, {
					params: { term, limit: effectiveLimit },
				})
			),
		enabled: (options?.enabled ?? true) && term.length > 0,
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

// --- Orders ---

/** Get today's order for a customer. Returns null if none. */
export function useGetTodayOrderByCustomer(
	customerId: string,
	options?: { enabled?: boolean }
) {
	return useQuery({
		queryKey: saleQueryKeys.todayOrderByCustomer(customerId),
		queryFn: () =>
			apiCall(() =>
				axiosInstance.get<ApiResult<OrderSummary>>(
					`${ORDER_BASE}/customer/${customerId}/today`
				)
			),
		enabled: (options?.enabled ?? true) && !!customerId,
	})
}

/** Get daily order summary (tổng hợp đơn đặt hàng trong ngày). Optional date: yyyy-MM-dd; default today UTC. */
export function useGetDailyOrderSummary(
	date: string | undefined,
	options?: { enabled?: boolean }
) {
	return useQuery({
		queryKey: saleQueryKeys.dailyOrderSummary(date),
		queryFn: () =>
			apiCall(() =>
				axiosInstance.get<ApiResult<DailyOrderSummaryItem[]>>(
					`${ORDER_BASE}/daily-summary`,
					date ? { params: { date } } : undefined
				)
			),
		enabled: options?.enabled ?? true,
	})
}

/** Create and sign a new order. Sends X-Transaction-Password header; body is customerId + items only. */
export function useCreateOrder() {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: (params: {
			customerId: string
			items: CreateOrderRequest['items']
			pin: string
		}) =>
			apiCall(() =>
				axiosInstance.post<ApiResult<Order>>(
					ORDER_BASE,
					{ customerId: params.customerId, items: params.items },
					{
						headers: {
							'X-Transaction-Password': params.pin,
						},
					}
				)
			),
		onSuccess: (_, variables) => {
			queryClient.invalidateQueries({
				queryKey: saleQueryKeys.todayOrderByCustomer(variables.customerId),
			})
			queryClient.invalidateQueries({
				queryKey: saleQueryKeys.dailyOrderSummary(undefined),
			})
		},
	})
}

/** Get an order by id (with items). */
export function useGetOrderById(
	orderId: string,
	options?: { enabled?: boolean }
) {
	return useQuery({
		queryKey: saleQueryKeys.order(orderId),
		queryFn: () =>
			apiCall(() =>
				axiosInstance.get<ApiResult<Order>>(`${ORDER_BASE}/${orderId}`)
			),
		enabled: (options?.enabled ?? true) && !!orderId,
	})
}

/** Update an existing order's items. Sends X-Transaction-Password header. */
export function useUpdateOrder() {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: (params: {
			orderId: string
			items: UpdateOrderRequest['items']
			pin: string
		}) =>
			apiCall(() =>
				axiosInstance.put<ApiResult<Order>>(
					`${ORDER_BASE}/${params.orderId}`,
					{ items: params.items },
					{
						headers: {
							'X-Transaction-Password': params.pin,
						},
					}
				)
			),
		onSuccess: (_, variables) => {
			queryClient.invalidateQueries({
				queryKey: saleQueryKeys.order(variables.orderId),
			})
			queryClient.invalidateQueries({
				queryKey: saleQueryKeys.dailyOrderSummary(undefined),
			})
		},
	})
}

// --- Products ---

/** Get all products. */
export function useGetAllProducts(options?: { enabled?: boolean }) {
	return useQuery({
		queryKey: saleQueryKeys.allProducts,
		queryFn: () =>
			apiCall(() => axiosInstance.get<ApiResult<Product[]>>(PRODUCT_BASE)),
		enabled: options?.enabled ?? true,
	})
}

/** Fetch product detail by id (for use in select handlers). */
export async function fetchProductDetail(
	productId: string
): Promise<ApiResult<ProductDetail>> {
	return apiCall(() =>
		axiosInstance.get<ApiResult<ProductDetail>>(`${PRODUCT_BASE}/${productId}`)
	)
}

/** Get product by id. */
export function useGetProductById(
	productId: string,
	options?: { enabled?: boolean }
) {
	return useQuery({
		queryKey: saleQueryKeys.product(productId),
		queryFn: () =>
			apiCall(() =>
				axiosInstance.get<ApiResult<ProductDetail>>(
					`${PRODUCT_BASE}/${productId}`
				)
			),
		enabled: (options?.enabled ?? true) && !!productId,
	})
}

/** Search products by code or name. */
export function useSearchProducts(
	params: { term: string; limit?: number },
	options?: { enabled?: boolean }
) {
	const { term, limit } = params
	const effectiveLimit = limit && limit > 0 && limit <= 50 ? limit : 20
	return useQuery({
		queryKey: saleQueryKeys.productSearch(term, effectiveLimit),
		queryFn: () =>
			apiCall(() =>
				axiosInstance.get<ApiResult<Product[]>>(`${PRODUCT_BASE}/search`, {
					params: { term, limit: effectiveLimit },
				})
			),
		enabled: (options?.enabled ?? true) && term.length > 0,
	})
}

/** Create a new product. */
export function useCreateProduct() {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: (body: CreateProductRequest) =>
			apiCall(() =>
				axiosInstance.post<ApiResult<ProductDetail>>(PRODUCT_BASE, body)
			),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: saleQueryKeys.allProducts })
		},
	})
}

/** Update an existing product. */
export function useUpdateProduct() {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: ({ id, body }: { id: string; body: UpdateProductRequest }) =>
			apiCall(() =>
				axiosInstance.put<ApiResult<ProductDetail>>(
					`${PRODUCT_BASE}/${id}`,
					body
				)
			),
		onSuccess: (_, variables) => {
			queryClient.invalidateQueries({
				queryKey: saleQueryKeys.product(variables.id),
			})
			queryClient.invalidateQueries({ queryKey: saleQueryKeys.allProducts })
		},
	})
}

/** Delete a product (soft delete). */
export function useDeleteProduct() {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: (productId: string) =>
			apiCall(() =>
				axiosInstance.delete<ApiResult<boolean>>(`${PRODUCT_BASE}/${productId}`)
			),
		onSuccess: (_, productId) => {
			queryClient.invalidateQueries({
				queryKey: saleQueryKeys.product(productId),
			})
			queryClient.invalidateQueries({ queryKey: saleQueryKeys.allProducts })
		},
	})
}
