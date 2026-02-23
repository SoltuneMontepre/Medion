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
	useGetProductById,
	useUpdateProduct,
} from '../../../services/Sale/saleApi'
import type { UpdateProductRequest } from '../../../services/Sale/types'
import type { ApiResult } from '../../../services/apiResult'

const PRODUCTS_PATH = '/products'

/** Sửa sản phẩm */
const EditProductPage = (): React.JSX.Element => {
	const { id } = useParams<{ id: string }>()
	const navigate = useNavigate()
	const firstInputRef = useRef<HTMLInputElement>(null)
	const [form, setForm] = useState<UpdateProductRequest>({
		code: '',
		name: '',
		specification: '',
		type: '',
		packaging: '',
	})
	const [touched, setTouched] = useState({ code: false, name: false })
	const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({})

	const {
		data: productResult,
		isLoading,
		error,
	} = useGetProductById(id ?? '', {
		enabled: !!id,
	})
	const updateProduct = useUpdateProduct()

	const product = productResult?.isSuccess ? productResult.data : null

	useEffect(() => {
		if (product) {
			setForm({
				code: product.code,
				name: product.name,
				specification: product.specification ?? '',
				type: product.type ?? '',
				packaging: product.packaging ?? '',
			})
		}
	}, [product])

	useEffect(() => {
		if (product) firstInputRef.current?.focus()
	}, [product])

	const validate = (): boolean => {
		const err: Record<string, string> = {}
		if (!form.code.trim()) err.code = 'Mã sản phẩm là bắt buộc.'
		if (!form.name.trim()) err.name = 'Tên sản phẩm là bắt buộc.'
		setFieldErrors(err)
		return Object.keys(err).length === 0
	}

	const handleSubmit = async (e: React.FormEvent) => {
		e.preventDefault()
		if (!id) return
		setTouched({ code: true, name: true })
		if (!validate()) return

		const body: UpdateProductRequest = {
			code: form.code.trim(),
			name: form.name.trim(),
			specification: form.specification?.trim() ?? '',
			type: form.type?.trim() ?? '',
			packaging: form.packaging?.trim() ?? '',
		}

		const result = (await updateProduct.mutateAsync({
			id,
			body,
		})) as ApiResult<unknown>
		if (result.isSuccess) {
			addToast({ title: 'Cập nhật sản phẩm thành công', color: 'success' })
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

	if (!id) {
		return (
			<div className='p-6'>
				<p className='text-danger'>Thiếu mã sản phẩm.</p>
				<Button variant='flat' onPress={() => navigate(PRODUCTS_PATH)}>
					Quay lại
				</Button>
			</div>
		)
	}

	if (
		error ||
		(productResult && !productResult.isSuccess && !productResult.data)
	) {
		return (
			<div className='p-6'>
				<p className='text-danger mb-4'>
					{(error as { message?: string })?.message ??
						productResult?.message ??
						'Sản phẩm không tồn tại.'}
				</p>
				<Button variant='flat' onPress={() => navigate(PRODUCTS_PATH)}>
					Quay lại
				</Button>
			</div>
		)
	}

	if (isLoading || !product) {
		return (
			<div className='p-6 flex justify-center'>
				<Spinner />
			</div>
		)
	}

	return (
		<div className='p-6'>
			<Card className='max-w-2xl'>
				<CardHeader>
					<h1 className='text-xl font-semibold'>Sửa sản phẩm</h1>
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
							autoComplete='off'
						/>
						<Input
							label='Dạng (form)'
							placeholder='Ví dụ: Bột uống, Dung dịch'
							value={form.type}
							onValueChange={v => setForm(prev => ({ ...prev, type: v }))}
							autoComplete='off'
						/>
						<Input
							label='Dạng đóng gói'
							placeholder='Ví dụ: Gói, Chai'
							value={form.packaging}
							onValueChange={v => setForm(prev => ({ ...prev, packaging: v }))}
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
								isLoading={updateProduct.isPending}
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

export default EditProductPage
