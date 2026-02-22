import React, { useEffect, useRef, useState } from 'react'
import { Button, Card, CardBody, CardHeader, Input } from '@heroui/react'
import { addToast } from '@heroui/react'
import { useSetupTransactionPin } from '../../../services/Security/transactionPinApi'
import type { ApiResult } from '../../../services/apiResult'

const PIN_MIN_LENGTH = 4
const PIN_MAX_LENGTH = 12

/** Thiết lập mã PIN giao dịch – dùng khi ký đơn hàng. */
const TransactionPinPage = (): React.JSX.Element => {
	const pinInputRef = useRef<HTMLInputElement>(null)
	const [pin, setPin] = useState('')
	const [confirmPin, setConfirmPin] = useState('')
	const [pinError, setPinError] = useState('')
	const [confirmError, setConfirmError] = useState('')

	const setupPin = useSetupTransactionPin()

	useEffect(() => {
		pinInputRef.current?.focus()
	}, [])

	const validate = (): boolean => {
		let ok = true
		if (!pin.trim()) {
			setPinError('Mã PIN là bắt buộc.')
			ok = false
		} else if (pin.length < PIN_MIN_LENGTH || pin.length > PIN_MAX_LENGTH) {
			setPinError(`Mã PIN phải từ ${PIN_MIN_LENGTH} đến ${PIN_MAX_LENGTH} ký tự.`)
			ok = false
		} else {
			setPinError('')
		}
		if (pin !== confirmPin) {
			setConfirmError('Mã PIN xác nhận không khớp.')
			ok = false
		} else {
			setConfirmError('')
		}
		return ok
	}

	const handleSubmit = async (e: React.FormEvent) => {
		e.preventDefault()
		if (!validate()) return

		const result = (await setupPin.mutateAsync({
			plainPin: pin.trim(),
		})) as ApiResult<unknown>

		if (result.isSuccess) {
			addToast({
				title: 'Thiết lập mã PIN giao dịch thành công',
				color: 'success',
			})
			setPin('')
			setConfirmPin('')
			setPinError('')
			setConfirmError('')
			return
		}

		addToast({
			title:
				result.message ?? 'Không thể thiết lập mã PIN. Vui lòng thử lại sau.',
			color: 'danger',
		})
	}

	return (
		<div className="p-6 max-w-md">
			<Card>
				<CardHeader>
					<h1 className="text-xl font-semibold">Mã PIN giao dịch</h1>
				</CardHeader>
				<CardBody>
					<p className="text-default-500 text-sm mb-4">
						Mã PIN dùng để xác thực khi ký đơn hàng. Thiết lập hoặc đổi mã PIN tại
						đây.
					</p>
					<form onSubmit={handleSubmit} className="flex flex-col gap-4">
						<Input
							ref={pinInputRef}
							label="Mã PIN"
							placeholder="Nhập mã PIN (4–12 ký tự)"
							type="password"
							autoComplete="new-password"
							value={pin}
							onValueChange={v => {
								setPin(v)
								if (pinError) setPinError('')
							}}
							onBlur={() => {
								if (pin.trim() && (pin.length < PIN_MIN_LENGTH || pin.length > PIN_MAX_LENGTH)) {
									setPinError(`Mã PIN phải từ ${PIN_MIN_LENGTH} đến ${PIN_MAX_LENGTH} ký tự.`)
								}
							}}
							isInvalid={!!pinError}
							errorMessage={pinError}
							maxLength={PIN_MAX_LENGTH}
							description={`${PIN_MIN_LENGTH}–${PIN_MAX_LENGTH} ký tự`}
						/>
						<Input
							label="Xác nhận mã PIN"
							placeholder="Nhập lại mã PIN"
							type="password"
							autoComplete="new-password"
							value={confirmPin}
							onValueChange={v => {
								setConfirmPin(v)
								if (confirmError) setConfirmError('')
							}}
							onBlur={() => {
								if (confirmPin && pin !== confirmPin) {
									setConfirmError('Mã PIN xác nhận không khớp.')
								}
							}}
							isInvalid={!!confirmError}
							errorMessage={confirmError}
							maxLength={PIN_MAX_LENGTH}
						/>
						<Button
							type="submit"
							color="primary"
							isLoading={setupPin.isPending}
							isDisabled={!pin.trim() || !confirmPin.trim()}
						>
							Lưu mã PIN
						</Button>
					</form>
				</CardBody>
			</Card>
		</div>
	)
}

export default TransactionPinPage
