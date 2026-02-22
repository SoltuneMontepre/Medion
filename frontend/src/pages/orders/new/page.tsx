import React, { useCallback, useEffect, useRef, useState } from 'react'
import { useNavigate } from 'react-router'
import {
	Button,
	Card,
	CardBody,
	CardHeader,
	Input,
	Modal,
	ModalBody,
	ModalContent,
	ModalFooter,
	ModalHeader,
	Table,
	TableBody,
	TableCell,
	TableColumn,
	TableHeader,
	TableRow,
} from '@heroui/react'
import { addToast } from '@heroui/react'
import {
	fetchProductDetail,
	useCreateOrder,
	useGetTodayOrderByCustomer,
	useSearchCustomers,
	useSearchProducts,
} from '../../../services/Sale/saleApi'
import type {
	Customer,
	OrderSummary,
	Product,
	ProductDetail,
} from '../../../services/Sale/types'
import type { ApiResult } from '../../../services/apiResult'
import useAuth from '../../../hooks/useAuth'

const ORDERS_PATH = '/orders'

/** Format date as DD/MM/YYYY HH:mm */
function formatOrderDate(date: Date): string {
	const d = date.getDate().toString().padStart(2, '0')
	const m = (date.getMonth() + 1).toString().padStart(2, '0')
	const y = date.getFullYear()
	const h = date.getHours().toString().padStart(2, '0')
	const min = date.getMinutes().toString().padStart(2, '0')
	return `${d}/${m}/${y} ${h}:${min}`
}

/** Generate display order number: DH + YYYYMMDD + -001 */
function generateOrderNumber(): string {
	const now = new Date()
	const y = now.getFullYear()
	const m = (now.getMonth() + 1).toString().padStart(2, '0')
	const d = now.getDate().toString().padStart(2, '0')
	return `DH${y}${m}${d}-001`
}

function fullName(c: Customer): string {
	return [c.lastName, c.firstName].filter(Boolean).join(' ').trim() || '—'
}

interface ProductRow {
	key: string
	productId: string
	productCode: string
	productName: string
	specification: string
	type: string
	packaging: string
	quantity: string
	quantityError: string
}

const EMPTY_ROW: Omit<ProductRow, 'key'> = {
	productId: '',
	productCode: '',
	productName: '',
	specification: '',
	type: '',
	packaging: '',
	quantity: '',
	quantityError: '',
}

function parseQuantity(s: string): number | null {
	const n = parseInt(s.trim(), 10)
	if (Number.isNaN(n) || n <= 0 || s.trim() === '') return null
	if (n.toString() !== s.trim()) return null // no decimals
	return n
}

/** Đơn đặt hàng mới – Sale Admin (AC1–AC4) */
const NewOrderPage = (): React.JSX.Element => {
	const navigate = useNavigate()
	const { user } = useAuth()
	const customerSearchRef = useRef<HTMLInputElement>(null)

	const [orderCreatedAt] = useState(() => new Date())
	const [customerSearchTerm, setCustomerSearchTerm] = useState('')
	const [selectedCustomer, setSelectedCustomer] = useState<Customer | null>(null)
	const [customerDropdownOpen, setCustomerDropdownOpen] = useState(false)
	const [orderNumber, setOrderNumber] = useState<string | null>(null)
	const [productRows, setProductRows] = useState<ProductRow[]>([])
	const [confirmModalOpen, setConfirmModalOpen] = useState(false)
	const [pinValue, setPinValue] = useState('')
	const [viewTodayOrderModalOpen, setViewTodayOrderModalOpen] = useState(false)

	const { data: customerSearchResult } = useSearchCustomers(
		{ term: customerSearchTerm.trim(), limit: 20 },
		{ enabled: customerSearchTerm.trim().length > 0 }
	)
	const customers = customerSearchResult?.data ?? []

	const { data: todayOrderResult, refetch: refetchTodayOrder } =
		useGetTodayOrderByCustomer(selectedCustomer?.id ?? '', {
			enabled: !!selectedCustomer?.id,
		})
	const todayOrder: OrderSummary | null =
		todayOrderResult?.isSuccess && todayOrderResult?.data
			? todayOrderResult.data
			: null
	const customerHasOrderToday = !!todayOrder

	const createOrder = useCreateOrder()

	// AC1: Autofocus customer search
	useEffect(() => {
		customerSearchRef.current?.focus()
	}, [])

	// When customer selected, check today order and set order number if no order
	useEffect(() => {
		if (!selectedCustomer) {
			setOrderNumber(null)
			return
		}
		refetchTodayOrder()
	}, [selectedCustomer?.id, refetchTodayOrder])

	useEffect(() => {
		if (selectedCustomer && !customerHasOrderToday) {
			setOrderNumber(generateOrderNumber())
		} else {
			setOrderNumber(null)
		}
	}, [selectedCustomer, customerHasOrderToday])

	const addProductRow = useCallback(() => {
		setProductRows(prev => [
			...prev,
			{
				...EMPTY_ROW,
				key: `row-${Date.now()}-${prev.length}`,
			},
		])
	}, [])

	const updateProductRow = useCallback((key: string, patch: Partial<ProductRow>) => {
		setProductRows(prev =>
			prev.map(r => (r.key === key ? { ...r, ...patch } : r))
		)
	}, [])

	const removeProductRow = useCallback((key: string) => {
		setProductRows(prev => prev.filter(r => r.key !== key))
	}, [])

	// Product search per row: we use a single "active row" search state for simplicity (search term + which row)
	const [productSearchRowKey, setProductSearchRowKey] = useState<string | null>(null)
	const [productSearchTerm, setProductSearchTerm] = useState('')
	const { data: productSearchResult } = useSearchProducts(
		{ term: productSearchTerm.trim(), limit: 20 },
		{ enabled: productSearchTerm.trim().length > 0 && !!productSearchRowKey }
	)
	const productSuggestions: Product[] = productSearchResult?.data ?? []

	const handleSelectCustomer = useCallback((c: Customer) => {
		setSelectedCustomer(c)
		setCustomerSearchTerm('')
		setCustomerDropdownOpen(false)
	}, [])

	const handleSelectProduct = useCallback(
		async (rowKey: string, product: Product) => {
			const res = await fetchProductDetail(product.id)
			if (!res.isSuccess || !res.data) {
				addToast({ title: 'Không tải được chi tiết sản phẩm', color: 'danger' })
				return
			}
			const d = res.data as ProductDetail
			updateProductRow(rowKey, {
				productId: d.id,
				productCode: d.code,
				productName: d.name,
				specification: d.specification,
				type: d.type,
				packaging: d.packaging,
			})
			setProductSearchRowKey(null)
			setProductSearchTerm('')
		},
		[updateProductRow]
	)

	const validateQuantity = useCallback((q: string): string => {
		const n = parseQuantity(q)
		if (n === null) return 'Số lượng sản phẩm không hợp lệ, vui lòng nhập lại số nguyên dương'
		return ''
	}, [])

	const validateRows = useCallback((): boolean => {
		let valid = true
		setProductRows(prev =>
			prev.map(r => {
				const err = validateQuantity(r.quantity)
				if (err) valid = false
				return { ...r, quantityError: err }
			})
		)
		return valid
	}, [validateQuantity])

	const canSave =
		!!selectedCustomer &&
		!customerHasOrderToday &&
		productRows.length > 0 &&
		productRows.every(
			r =>
				r.productId &&
				parseQuantity(r.quantity) !== null &&
				!validateQuantity(r.quantity)
		)

	const handleQuantityBlur = useCallback(
		(key: string) => {
			const row = productRows.find(r => r.key === key)
			if (!row) return
			updateProductRow(key, { quantityError: validateQuantity(row.quantity) })
		},
		[productRows, updateProductRow, validateQuantity]
	)

	const handleSaveClick = () => {
		// AC4: validate
		const hasInvalidQuantity = productRows.some(
			r => !r.productId || parseQuantity(r.quantity) === null
		)
		if (hasInvalidQuantity) {
			addToast({
				title: 'Vui lòng kiểm tra lại thông tin sản phẩm',
				color: 'danger',
			})
			return
		}
		setConfirmModalOpen(true)
		setPinValue('')
	}

	const handleConfirmSubmit = async () => {
		if (!selectedCustomer || !user?.id || !pinValue.trim()) return
		const items = productRows
			.filter(r => r.productId && parseQuantity(r.quantity) !== null)
			.map(r => ({
				productId: r.productId,
				quantity: parseQuantity(r.quantity)!,
			}))
		const result = (await createOrder.mutateAsync({
			customerId: selectedCustomer.id,
			salesStaffId: user.id,
			pin: pinValue.trim(),
			items,
		})) as ApiResult<unknown>
		if (result.isSuccess) {
			addToast({
				title: 'Lưu và ký đơn hàng thành công',
				color: 'success',
			})
			setConfirmModalOpen(false)
			navigate(ORDERS_PATH, { replace: true })
			return
		}
		// Trường hợp hệ thống lỗi (AC4)
		const isSystemError =
			(result as ApiResult<unknown>).statusCode >= 500 ||
			(result as ApiResult<unknown>).statusCode === 0
		addToast({
			title: isSystemError
				? 'Có lỗi xảy ra, vui lòng thử lại sau'
				: result.message ??
					'Ký số không thành công, vui lòng kiểm tra lại thiết bị hoặc mã PIN',
			color: 'warning',
		})
	}

	const openViewTodayOrderModal = () => setViewTodayOrderModalOpen(true)
	const closeViewTodayOrderModal = () => setViewTodayOrderModalOpen(false)

	return (
		<div className="p-6 max-w-5xl">
			<Card>
				<CardHeader>
					<h1 className="text-xl font-semibold">Đơn đặt hàng mới</h1>
				</CardHeader>
				<CardBody className="flex flex-col gap-6">
					{/* AC1: Ngày tạo đơn - read-only, DD/MM/YYYY HH:mm */}
					<div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
						<Input
							label="Ngày Tạo Đơn"
							value={formatOrderDate(orderCreatedAt)}
							isReadOnly
							description="Định dạng: DD/MM/YYYY HH:mm"
						/>
						{orderNumber && (
							<Input
								label="Số Đơn Hàng"
								value={orderNumber}
								isReadOnly
							/>
						)}
					</div>

					{/* AC2: Customer search - [Mã KH] - [Tên KH] - [SĐT] - [Địa chỉ] */}
					<div className="relative">
						<Input
							ref={customerSearchRef}
							label="Mã Khách Hàng / Tên / SĐT"
							placeholder="Nhập mã, tên hoặc số điện thoại..."
							value={customerSearchTerm}
							onValueChange={v => {
								setCustomerSearchTerm(v)
								setCustomerDropdownOpen(true)
								if (!v.trim()) setSelectedCustomer(null)
							}}
							onFocus={() => customerSearchTerm && setCustomerDropdownOpen(true)}
							onBlur={() =>
								setTimeout(() => setCustomerDropdownOpen(false), 200)
							}
						/>
						{customerDropdownOpen && customerSearchTerm.trim() && (
							<ul
								className="absolute z-10 mt-1 w-full max-h-60 overflow-auto rounded-medium border border-divider bg-content1 shadow-lg py-1"
								role="listbox"
							>
								{customers.length === 0 ? (
									<li className="px-3 py-2 text-default-500 text-sm">
										Không tìm thấy khách hàng phù hợp
									</li>
								) : (
									customers.map(c => (
										<li
											key={c.id}
											role="option"
											className="px-3 py-2 text-sm cursor-pointer hover:bg-content2"
											onMouseDown={() => handleSelectCustomer(c)}
										>
											{c.code} - {fullName(c)} - {c.phoneNumber} -{' '}
											{c.address || '—'}
										</li>
									))
								)}
							</ul>
						)}
					</div>

					{/* Selected customer fields (read-only) */}
					{selectedCustomer && (
						<>
							<div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
								<Input
									label="Mã KH"
									value={selectedCustomer.code}
									isReadOnly
								/>
								<Input
									label="Tên KH"
									value={fullName(selectedCustomer)}
									isReadOnly
								/>
								<Input
									label="SĐT"
									value={selectedCustomer.phoneNumber}
									isReadOnly
								/>
								<Input
									label="Địa chỉ"
									value={selectedCustomer.address || '—'}
									isReadOnly
								/>
							</div>

							{/* Case 1: already has order today */}
							{customerHasOrderToday && todayOrder && (
								<div className="rounded-medium border border-danger bg-danger/10 p-4">
									<p className="text-danger font-medium">
										Khách hàng này đã có đơn hàng hôm nay
									</p>
									<Button
										size="sm"
										variant="flat"
										color="primary"
										className="mt-2"
										onPress={openViewTodayOrderModal}
									>
										Xem đơn hàng của khách
									</Button>
								</div>
							)}
						</>
					)}

					{/* AC3: Product rows - only when customer valid (no order today) */}
					{selectedCustomer && !customerHasOrderToday && (
						<>
							<div className="flex items-center justify-between gap-4 flex-wrap">
								<h2 className="text-lg font-medium">Danh sách sản phẩm</h2>
								<Button color="primary" onPress={addProductRow}>
									Thêm Sản Phẩm
								</Button>
							</div>

							{productRows.length > 0 && (
								<Table aria-label="Sản phẩm đặt hàng">
									<TableHeader>
										<TableColumn width={40}>STT</TableColumn>
										<TableColumn>Mã SP / Tìm kiếm</TableColumn>
										<TableColumn>Tên SP</TableColumn>
										<TableColumn>Quy Cách</TableColumn>
										<TableColumn>Dạng SP</TableColumn>
										<TableColumn>Dạng đóng gói</TableColumn>
										<TableColumn width={100}>Số Lượng</TableColumn>
										<TableColumn width={60} align="center">
											Thao tác
										</TableColumn>
									</TableHeader>
									<TableBody>
										{productRows.map((row, idx) => (
											<TableRow key={row.key}>
												<TableCell>{idx + 1}</TableCell>
												<TableCell>
													{row.productId ? (
														row.productCode
													) : (
														<div className="relative">
															<Input
																size="sm"
																placeholder="Mã hoặc tên sản phẩm..."
																value={
																	productSearchRowKey === row.key
																		? productSearchTerm
																		: ''
																}
																onFocus={() => {
																	setProductSearchRowKey(row.key)
																	setProductSearchTerm('')
																}}
																onValueChange={v => {
																	setProductSearchTerm(v)
																	if (v) setProductSearchRowKey(row.key)
																}}
															/>
															{productSearchRowKey === row.key &&
																productSearchTerm.trim() && (
																<ul
																	className="absolute z-10 left-0 right-0 mt-1 max-h-48 overflow-auto rounded-medium border border-divider bg-content1 shadow-lg py-1"
																	role="listbox"
																>
																	{productSuggestions.length === 0 ? (
																		<li className="px-3 py-2 text-default-500 text-sm">
																			Không tìm thấy sản phẩm phù hợp
																		</li>
																	) : (
																		productSuggestions.map(p => (
																			<li
																				key={p.id}
																				role="option"
																				className="px-3 py-2 text-sm cursor-pointer hover:bg-content2"
																				onMouseDown={() =>
																					handleSelectProduct(row.key, p)
																				}
																			>
																				{p.code} - {p.name}
																			</li>
																		))
																	)}
																</ul>
															)}
														</div>
													)}
												</TableCell>
												<TableCell>{row.productName || '—'}</TableCell>
												<TableCell>{row.specification || '—'}</TableCell>
												<TableCell>{row.type || '—'}</TableCell>
												<TableCell>{row.packaging || '—'}</TableCell>
												<TableCell>
													<div>
														<Input
															type="number"
															size="sm"
															placeholder="SL"
															value={row.quantity}
															onValueChange={v =>
																updateProductRow(row.key, {
																	quantity: v,
																	quantityError: validateQuantity(v),
																})
															}
															onBlur={() => handleQuantityBlur(row.key)}
															isInvalid={!!row.quantityError}
														/>
														{row.quantityError && (
															<p className="text-danger text-tiny mt-1">
																{row.quantityError}
															</p>
														)}
													</div>
												</TableCell>
												<TableCell align="center">
													<Button
														size="sm"
														variant="light"
														color="danger"
														onPress={() => removeProductRow(row.key)}
													>
														Xóa
													</Button>
												</TableCell>
											</TableRow>
										))}
									</TableBody>
								</Table>
							)}
						</>
					)}

					{/* AC1: Lưu Đơn disabled by default; AC3 Case 1: disable when quantity invalid */}
					<div className="flex justify-end pt-4">
						<Button
							color="primary"
							onPress={handleSaveClick}
							isDisabled={!canSave}
						>
							Lưu Đơn
						</Button>
					</div>
				</CardBody>
			</Card>

			{/* AC4: Confirmation modal - customer, products, PIN */}
			<Modal
				isOpen={confirmModalOpen}
				onOpenChange={setConfirmModalOpen}
				size="2xl"
			>
				<ModalContent>
					<ModalHeader>Xác nhận ký số đơn hàng</ModalHeader>
					<ModalBody>
						{selectedCustomer && (
							<>
								<p className="font-medium">Thông tin khách hàng</p>
								<p className="text-sm text-default-600">
									{selectedCustomer.code} - {fullName(selectedCustomer)} -{' '}
									{selectedCustomer.phoneNumber}
								</p>
								<p className="font-medium mt-4">Danh sách sản phẩm</p>
								<ul className="list-disc list-inside text-sm text-default-600">
									{productRows
										.filter(r => r.productId && parseQuantity(r.quantity) !== null)
										.map((r, i) => (
											<li key={r.key}>
												{r.productCode} - {r.productName} x{' '}
												{parseQuantity(r.quantity)}
											</li>
										))}
								</ul>
								<p className="text-default-500 text-sm mt-2">
									Tổng tiền: Theo quy định
								</p>
								<Input
									label="Mã PIN"
									type="password"
									placeholder="Nhập mã PIN"
									value={pinValue}
									onValueChange={setPinValue}
									className="mt-4"
								/>
							</>
						)}
					</ModalBody>
					<ModalFooter>
						<Button variant="light" onPress={() => setConfirmModalOpen(false)}>
							Hủy
						</Button>
						<Button
							color="primary"
							onPress={handleConfirmSubmit}
							isDisabled={!pinValue.trim()}
							isLoading={createOrder.isPending}
						>
							Xác nhận ký số
						</Button>
					</ModalFooter>
				</ModalContent>
			</Modal>

			{/* View today order modal */}
			<Modal isOpen={viewTodayOrderModalOpen} onOpenChange={setViewTodayOrderModalOpen}>
				<ModalContent>
					<ModalHeader>Đơn hàng của khách hôm nay</ModalHeader>
					<ModalBody>
						{todayOrder && (
							<div className="space-y-2 text-sm">
								<p>
									<strong>Số đơn:</strong> {todayOrder.orderNumber}
								</p>
								<p>
									<strong>Ngày:</strong> {todayOrder.orderDate}
								</p>
								<p>
									<strong>Trạng thái:</strong>{' '}
									{todayOrder.status === 'Signed' ? 'Đã ký' : 'Nháp'}
								</p>
							</div>
						)}
					</ModalBody>
					<ModalFooter>
						<Button onPress={closeViewTodayOrderModal}>Đóng</Button>
					</ModalFooter>
				</ModalContent>
			</Modal>
		</div>
	)
}

export default NewOrderPage
