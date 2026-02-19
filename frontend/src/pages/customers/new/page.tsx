import React, { useEffect, useRef, useState } from 'react'
import { useNavigate } from 'react-router'
import { Button, Card, CardBody, CardHeader, Input, Modal, ModalBody, ModalContent, ModalFooter, ModalHeader } from '@heroui/react'
import { addToast } from '@heroui/react'
import { useCreateCustomer } from '../../../services/Sale/saleApi'
import type { CreateCustomerRequest } from '../../../services/Sale/types'
import type { ApiResult } from '../../../services/apiResult'

const CUSTOMERS_PATH = '/customers'

const PHONE_REGEX = /^\+?[0-9\s\-()]+$/

/** Chuyển "Tên khách hàng" (một trường) thành firstName + lastName cho API. */
function fullNameToFirstLast(fullName: string): { firstName: string; lastName: string } {
	const t = fullName.trim()
	if (!t) return { firstName: '', lastName: '' }
	const parts = t.split(/\s+/)
	const lastName = parts[0] ?? ''
	const firstName = parts.slice(1).join(' ') || lastName
	return { firstName, lastName }
}

/** Thông tin khách hàng mới – Sale Admin (AC1–AC5) */
const NewCustomerPage = (): React.JSX.Element => {
	const navigate = useNavigate()
	const firstInputRef = useRef<HTMLInputElement>(null)
	const [form, setForm] = useState({
		fullName: '',
		address: '',
		phoneNumber: '',
	})
	const [touched, setTouched] = useState({ fullName: false, address: false, phoneNumber: false })
	const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({})
	const [cancelModalOpen, setCancelModalOpen] = useState(false)

	const createCustomer = useCreateCustomer()

	// AC1: focus vào trường nhập liệu đầu tiên
	useEffect(() => {
		firstInputRef.current?.focus()
	}, [])

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
		setTouched({ fullName: true, address: true, phoneNumber: true })
		if (!validate()) return

		const { firstName, lastName } = fullNameToFirstLast(form.fullName)
		const body: CreateCustomerRequest = {
			firstName,
			lastName,
			address: form.address.trim(),
			phoneNumber: form.phoneNumber.trim(),
		}

		const result = (await createCustomer.mutateAsync(body)) as ApiResult<unknown>
		if (result.isSuccess) {
			addToast({
				title: 'Tạo khách hàng thành công',
				color: 'success',
			})
			navigate(CUSTOMERS_PATH, { replace: true })
			return
		}
		// AC3, AC4: giữ nguyên dữ liệu, hiển thị lỗi dưới từng trường
		const errors: Record<string, string> = {}
		if (result.errors) {
			for (const [key, messages] of Object.entries(result.errors)) {
				const msg = Array.isArray(messages) ? messages[0] : String(messages)
				if (key === 'PhoneNumber') {
					errors.phoneNumber = msg ?? 'Số điện thoại này đã tồn tại trong hệ thống. Vui lòng kiểm tra lại.'
				} else if (key === 'FirstName' || key === 'LastName') {
					errors.fullName = (errors.fullName ? `${errors.fullName} ` : '') + (msg ?? '')
				} else if (key === 'Address') {
					errors.address = msg ?? ''
				} else {
					errors[key] = msg ?? ''
				}
			}
		}
		if (result.message && !Object.keys(errors).length) {
			errors.form = result.message
		}
		setFieldErrors(errors)
	}

	const handleCancelClick = () => setCancelModalOpen(true)

	const handleCancelModalClose = () => setCancelModalOpen(false)

	const handleCancelConfirm = () => {
		setCancelModalOpen(false)
		navigate(CUSTOMERS_PATH, { replace: true })
	}

	const fullNameError = fieldErrors.fullName || (touched.fullName && !form.fullName.trim() ? 'Tên khách hàng là bắt buộc.' : undefined)
	const addressError = fieldErrors.address || (touched.address && !form.address.trim() ? 'Địa chỉ là bắt buộc.' : undefined)
	const phoneError = fieldErrors.phoneNumber
		|| (touched.phoneNumber && !form.phoneNumber.trim() ? 'Số điện thoại là bắt buộc.' : undefined)
		|| (touched.phoneNumber && form.phoneNumber.trim() && !PHONE_REGEX.test(form.phoneNumber.replace(/\s/g, '')) ? 'Số điện thoại không hợp lệ.' : undefined)

	return (
		<div className="p-6">
			<Card className="max-w-2xl">
				<CardHeader>
					<h1 className="text-xl font-semibold">Thông tin khách hàng mới</h1>
				</CardHeader>
				<CardBody>
					<form onSubmit={handleSubmit} className="flex flex-col gap-4">
						<Input
							ref={firstInputRef}
							label="Tên khách hàng"
							placeholder="Nhập họ tên khách hàng"
							value={form.fullName}
							onValueChange={v => setForm(prev => ({ ...prev, fullName: v }))}
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
							onValueChange={v => setForm(prev => ({ ...prev, phoneNumber: v }))}
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
								onPress={handleCancelClick}
							>
								Hủy tạo khách hàng mới
							</Button>
							<Button
								type="submit"
								color="primary"
								isLoading={createCustomer.isPending}
							>
								Lưu
							</Button>
						</div>
					</form>
				</CardBody>
			</Card>

			{/* AC5: Pop-up xác nhận hủy */}
			<Modal isOpen={cancelModalOpen} onClose={handleCancelModalClose}>
				<ModalContent>
					<ModalHeader>Xác nhận hủy</ModalHeader>
					<ModalBody>
						<p>
							Bạn có chắc chắn muốn hủy tạo khách hàng mới? Mọi thông tin đã nhập sẽ không được lưu.
						</p>
					</ModalBody>
					<ModalFooter>
						<Button variant="flat" onPress={handleCancelModalClose}>
							Hủy bỏ
						</Button>
						<Button color="primary" onPress={handleCancelConfirm}>
							Đồng ý
						</Button>
					</ModalFooter>
				</ModalContent>
			</Modal>
		</div>
	)
}

export default NewCustomerPage
