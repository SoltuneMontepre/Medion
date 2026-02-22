import React, { useEffect, useRef, useState } from 'react'
import { useNavigate, useParams } from 'react-router'
import {
	Button,
	Card,
	CardBody,
	CardHeader,
	Input,
	Spinner,
} from '@heroui/react'
import { addToast } from '@heroui/react'
import {
	useGetCustomerById,
	useUpdateCustomer,
} from '../../../services/Sale/saleApi'
import type { UpdateCustomerRequest } from '../../../services/Sale/types'
import type { ApiResult } from '../../../services/apiResult'

const CUSTOMERS_PATH = '/customers'
const PHONE_REGEX = /^\+?[0-9\s\-()]+$/

/** Sửa khách hàng */
const EditCustomerPage = (): React.JSX.Element => {
	const { id } = useParams<{ id: string }>()
	const navigate = useNavigate()
	const firstInputRef = useRef<HTMLInputElement>(null)
	const [form, setForm] = useState({
		fullName: '',
		address: '',
		phoneNumber: '',
	})
	const [touched, setTouched] = useState({
		fullName: false,
		address: false,
		phoneNumber: false,
	})
	const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({})

	const { data: customerResult, isLoading, error } = useGetCustomerById(
		id ?? '',
		{ enabled: !!id }
	)
	const updateCustomer = useUpdateCustomer()

	const customer = customerResult?.isSuccess ? customerResult.data : null

	const fullNameToFirstLast = (firstName: string, lastName: string): string =>
		[lastName, firstName].filter(Boolean).join(' ').trim() || ''

	useEffect(() => {
		if (customer) {
			setForm({
				fullName: fullNameToFirstLast(customer.firstName, customer.lastName),
				address: customer.address ?? '',
				phoneNumber: customer.phoneNumber ?? '',
			})
		}
	}, [customer])

	useEffect(() => {
		if (customer) firstInputRef.current?.focus()
	}, [customer])

	const firstLastToFull = (fullName: string): { firstName: string; lastName: string } => {
		const t = fullName.trim()
		if (!t) return { firstName: '', lastName: '' }
		const parts = t.split(/\s+/)
		const lastName = parts[0] ?? ''
		const firstName = parts.slice(1).join(' ') || lastName
		return { firstName, lastName }
	}

	const validate = (): boolean => {
		const err: Record<string, string> = {}
		if (!form.fullName.trim()) err.fullName = 'Tên khách hàng là bắt buộc.'
		if (!form.address.trim()) err.address = 'Địa chỉ là bắt buộc.'
		if (!form.phoneNumber.trim()) {
			err.phoneNumber = 'Số điện thoại là bắt buộc.'
		} else if (!PHONE_REGEX.test(form.phoneNumber.replace(/\s/g, ''))) {
			err.phoneNumber = 'Số điện thoại không hợp lệ.'
		}
		setFieldErrors(err)
		return Object.keys(err).length === 0
	}

	const handleSubmit = async (e: React.FormEvent) => {
		e.preventDefault()
		if (!id) return
		setTouched({ fullName: true, address: true, phoneNumber: true })
		if (!validate()) return

		const { firstName, lastName } = firstLastToFull(form.fullName)
		const body: UpdateCustomerRequest = {
			firstName,
			lastName,
			address: form.address.trim(),
			phoneNumber: form.phoneNumber.trim(),
		}

		const result = (await updateCustomer.mutateAsync({
			id,
			body,
		})) as ApiResult<unknown>
		if (result.isSuccess) {
			addToast({ title: 'Cập nhật khách hàng thành công', color: 'success' })
			navigate(CUSTOMERS_PATH, { replace: true })
			return
		}
		const errors: Record<string, string> = {}
		if (result.errors) {
			for (const [key, messages] of Object.entries(result.errors)) {
				const msg = Array.isArray(messages) ? messages[0] : String(messages)
				if (key === 'PhoneNumber') {
					errors.phoneNumber =
						msg ?? 'Số điện thoại này đã tồn tại trong hệ thống. Vui lòng kiểm tra lại.'
				} else if (key === 'FirstName' || key === 'LastName') {
					errors.fullName = (errors.fullName ? `${errors.fullName} ` : '') + (msg ?? '')
				} else if (key === 'Address') {
					errors.address = msg ?? ''
				} else {
					errors[key] = msg ?? ''
				}
			}
		}
		if (result.message && !Object.keys(errors).length) errors.form = result.message
		setFieldErrors(errors)
	}

	if (!id) {
		return (
			<div className="p-6">
				<p className="text-danger">Thiếu mã khách hàng.</p>
				<Button variant="flat" onPress={() => navigate(CUSTOMERS_PATH)}>
					Quay lại
				</Button>
			</div>
		)
	}

	if (
		error ||
		(customerResult && !customerResult.isSuccess && !customerResult.data)
	) {
		return (
			<div className="p-6">
				<p className="text-danger mb-4">
					{(error as { message?: string })?.message ??
						customerResult?.message ??
						'Khách hàng không tồn tại.'}
				</p>
				<Button variant="flat" onPress={() => navigate(CUSTOMERS_PATH)}>
					Quay lại
				</Button>
			</div>
		)
	}

	if (isLoading || !customer) {
		return (
			<div className="p-6 flex justify-center">
				<Spinner />
			</div>
		)
	}

	const fullNameError =
		fieldErrors.fullName ||
		(touched.fullName && !form.fullName.trim() ? 'Tên khách hàng là bắt buộc.' : undefined)
	const addressError =
		fieldErrors.address ||
		(touched.address && !form.address.trim() ? 'Địa chỉ là bắt buộc.' : undefined)
	const phoneError =
		fieldErrors.phoneNumber ||
		(touched.phoneNumber && !form.phoneNumber.trim()
			? 'Số điện thoại là bắt buộc.'
			: undefined) ||
		(touched.phoneNumber &&
		form.phoneNumber.trim() &&
		!PHONE_REGEX.test(form.phoneNumber.replace(/\s/g, ''))
			? 'Số điện thoại không hợp lệ.'
			: undefined)

	return (
		<div className="p-6">
			<Card className="max-w-2xl">
				<CardHeader>
					<h1 className="text-xl font-semibold">Sửa khách hàng</h1>
					<p className="text-sm text-default-500">Mã KH: {customer.code}</p>
				</CardHeader>
				<CardBody>
					<form onSubmit={handleSubmit} className="flex flex-col gap-4">
						<Input
							ref={firstInputRef}
							label="Tên khách hàng"
							placeholder="Nhập họ tên khách hàng"
							value={form.fullName}
							onValueChange={v =>
								setForm(prev => ({ ...prev, fullName: v }))
							}
							onBlur={() => setTouched(prev => ({ ...prev, fullName: true }))}
							isInvalid={!!fullNameError}
							errorMessage={fullNameError}
							isRequired
							autoComplete="name"
						/>
						<Input
							label="Địa chỉ"
							placeholder="Nhập địa chỉ"
							value={form.address}
							onValueChange={v => setForm(prev => ({ ...prev, address: v }))}
							onBlur={() => setTouched(prev => ({ ...prev, address: true }))}
							isInvalid={!!addressError}
							errorMessage={addressError}
							isRequired
							autoComplete="street-address"
						/>
						<Input
							label="Số điện thoại"
							placeholder="Ví dụ: 0901234567 hoặc +84901234567"
							value={form.phoneNumber}
							onValueChange={v =>
								setForm(prev => ({ ...prev, phoneNumber: v }))
							}
							onBlur={() => setTouched(prev => ({ ...prev, phoneNumber: true }))}
							isInvalid={!!phoneError}
							errorMessage={phoneError}
							isRequired
							autoComplete="tel"
						/>
						{fieldErrors.form && (
							<p className="text-small text-danger">{fieldErrors.form}</p>
						)}
						<div className="flex gap-2 justify-end pt-2">
							<Button
								type="button"
								variant="flat"
								onPress={() => navigate(CUSTOMERS_PATH)}
							>
								Hủy
							</Button>
							<Button
								type="submit"
								color="primary"
								isLoading={updateCustomer.isPending}
							>
								Lưu
							</Button>
						</div>
					</form>
				</CardBody>
			</Card>
		</div>
	)
}

export default EditCustomerPage
