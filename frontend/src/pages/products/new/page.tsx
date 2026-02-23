import React, { useEffect, useRef, useState } from 'react'
import { useNavigate } from 'react-router'
import { Button, Card, CardBody, CardHeader, Input } from '@heroui/react'
import { addToast } from '@heroui/react'
import { useCreateProduct } from '../../../services/Sale/saleApi'
import type { CreateProductRequest } from '../../../services/Sale/types'
import type { ApiResult } from '../../../services/apiResult'

const PRODUCTS_PATH = '/products'

/** Thêm sản phẩm mới */
const NewProductPage = (): React.JSX.Element => {
	const navigate = useNavigate()
	const firstInputRef = useRef<HTMLInputElement>(null)
	const [form, setForm] = useState<CreateProductRequest>({
		code: '',
		name: '',
		specification: '',
		type: '',
		packaging: '',
	})
	const [touched, setTouched] = useState({
		code: false,
		name: false,
		specification: false,
		type: false,
		packaging: false,
	})
	const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({})

	const createProduct = useCreateProduct()

	useEffect(() => {
		firstInputRef.current?.focus()
	}, [])

	const validate = (): boolean => {
		const err: Record<string, string> = {}
		if (!form.code.trim()) err.code = 'Mã sản phẩm là bắt buộc.'
		if (!form.name.trim()) err.name = 'Tên sản phẩm là bắt buộc.'
		if (!form.specification.trim()) err.specification = 'Quy cách là bắt buộc.'
		if (!form.type.trim()) err.type = 'Dạng sản phẩm là bắt buộc.'
		if (!form.packaging.trim()) err.packaging = 'Dạng đóng gói là bắt buộc.'
		setFieldErrors(err)
		return Object.keys(err).length === 0
	}

	const handleSubmit = async (e: React.FormEvent) => {
		e.preventDefault()
		setTouched({
			code: true,
			name: true,
			specification: true,
			type: true,
			packaging: true,
		})
		if (!validate()) return

		const body: CreateProductRequest = {
			code: form.code.trim(),
			name: form.name.trim(),
			specification: form.specification?.trim() ?? '',
			type: form.type?.trim() ?? '',
			packaging: form.packaging?.trim() ?? '',
		}

		const result = (await createProduct.mutateAsync(body)) as ApiResult<unknown>
		if (result.isSuccess) {
			addToast({ title: 'Tạo sản phẩm thành công', color: 'success' })
			navigate(PRODUCTS_PATH, { replace: true })
			return
		}
		const errors: Record<string, string> = {}
		if (result.errors) {
			for (const [key, messages] of Object.entries(result.errors)) {
				const msg = Array.isArray(messages) ? messages[0] : String(messages)
				if (key === 'Code') errors.code = msg ?? ''
				else if (key === 'Name') errors.name = msg ?? ''
				else errors[key] = msg ?? ''
			}
		}
		if (result.message && !Object.keys(errors).length)
			errors.form = result.message
		setFieldErrors(errors)
	}

	return (
		<div className='p-6'>
			<Card className='max-w-2xl'>
				<CardHeader>
					<h1 className='text-xl font-semibold'>Thêm sản phẩm</h1>
				</CardHeader>
				<CardBody>
					<form onSubmit={handleSubmit} className='flex flex-col gap-4'>
						<Input
							ref={firstInputRef}
							label='Mã sản phẩm'
							placeholder='Ví dụ: SP001'
							value={form.code}
							onValueChange={v => setForm(prev => ({ ...prev, code: v }))}
							onBlur={() => setTouched(prev => ({ ...prev, code: true }))}
							isInvalid={
								!!(fieldErrors.code || (touched.code && !form.code.trim()))
							}
							errorMessage={
								fieldErrors.code ||
								(touched.code && !form.code.trim()
									? 'Mã sản phẩm là bắt buộc.'
									: undefined)
							}
							isRequired
							autoComplete='off'
						/>
						<Input
							label='Tên sản phẩm'
							placeholder='Nhập tên sản phẩm'
							value={form.name}
							onValueChange={v => setForm(prev => ({ ...prev, name: v }))}
							onBlur={() => setTouched(prev => ({ ...prev, name: true }))}
							isInvalid={
								!!(fieldErrors.name || (touched.name && !form.name.trim()))
							}
							errorMessage={
								fieldErrors.name ||
								(touched.name && !form.name.trim()
									? 'Tên sản phẩm là bắt buộc.'
									: undefined)
							}
							isRequired
							autoComplete='off'
						/>
						<Input
							label='Quy cách'
							placeholder='Ví dụ: 100gr, 250ml'
							value={form.specification}
							onValueChange={v =>
								setForm(prev => ({ ...prev, specification: v }))
							}
							onBlur={() =>
								setTouched(prev => ({ ...prev, specification: true }))
							}
							isInvalid={
								!!(
									fieldErrors.specification ||
									(touched.specification && !form.specification.trim())
								)
							}
							errorMessage={
								fieldErrors.specification ||
								(touched.specification && !form.specification.trim()
									? 'Quy cách là bắt buộc.'
									: undefined)
							}
							isRequired
							autoComplete='off'
						/>
						<Input
							label='Dạng sản phẩm'
							placeholder='Ví dụ: Bột uống, Dung dịch'
							value={form.type}
							onValueChange={v => setForm(prev => ({ ...prev, type: v }))}
							onBlur={() => setTouched(prev => ({ ...prev, type: true }))}
							isInvalid={
								!!(fieldErrors.type || (touched.type && !form.type.trim()))
							}
							errorMessage={
								fieldErrors.type ||
								(touched.type && !form.type.trim()
									? 'Dạng sản phẩm là bắt buộc.'
									: undefined)
							}
							isRequired
							autoComplete='off'
						/>
						<Input
							label='Dạng đóng gói'
							placeholder='Ví dụ: Gói, Chai'
							value={form.packaging}
							onValueChange={v => setForm(prev => ({ ...prev, packaging: v }))}
							onBlur={() => setTouched(prev => ({ ...prev, packaging: true }))}
							isInvalid={
								!!(
									fieldErrors.packaging ||
									(touched.packaging && !form.packaging.trim())
								)
							}
							errorMessage={
								fieldErrors.packaging ||
								(touched.packaging && !form.packaging.trim()
									? 'Dạng đóng gói là bắt buộc.'
									: undefined)
							}
							isRequired
							autoComplete='off'
						/>
						{fieldErrors.form && (
							<p className='text-small text-danger'>{fieldErrors.form}</p>
						)}
						<div className='flex gap-2 justify-end pt-2'>
							<Button
								type='button'
								variant='flat'
								onPress={() => navigate(PRODUCTS_PATH)}
							>
								Hủy
							</Button>
							<Button
								type='submit'
								color='primary'
								isLoading={createProduct.isPending}
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

export default NewProductPage
