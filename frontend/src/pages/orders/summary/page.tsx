import React, { useMemo, useState } from 'react'
import {
	Button,
	Card,
	CardBody,
	CardHeader,
	Divider,
	Input,
	Spinner,
	Table,
	TableBody,
	TableCell,
	TableColumn,
	TableHeader,
	TableRow,
} from '@heroui/react'
import { useGetDailyOrderSummary } from '../../../services/Sale/saleApi'

function todayYyyyMmDd(): string {
	const now = new Date()
	const y = now.getFullYear()
	const m = (now.getMonth() + 1).toString().padStart(2, '0')
	const d = now.getDate().toString().padStart(2, '0')
	return `${y}-${m}-${d}`
}

function formatDisplayDate(yyyyMmDd: string): string {
	const [y, m, d] = yyyyMmDd.split('-')
	return [d, m, y].filter(Boolean).join('/')
}

/** Bảng tổng hợp đơn đặt hàng – Sale Admin / NV phòng Kinh doanh */
const OrderSummaryPage = (): React.JSX.Element => {
	const [dateValue, setDateValue] = useState(todayYyyyMmDd)
	const dateForApi = dateValue || undefined

	const { data: summaryResult, isLoading, error } = useGetDailyOrderSummary(
		dateForApi
	)
	const rows = useMemo(() => {
		if (!summaryResult?.isSuccess || !summaryResult.data) return []
		return summaryResult.data
	}, [summaryResult])

	const handleSend = () => {
		// TODO: API call — send to Nhân viên phòng Kế hoạch + Kế toán kho
	}

	return (
		<div className='p-6 max-w-5xl'>
			<Card>
				<CardHeader className='flex flex-col gap-2'>
					<div className='flex flex-row items-center justify-between gap-4 flex-wrap w-full'>
						<h1 className='text-xl font-semibold'>
							Bảng tổng hợp đơn đặt hàng
						</h1>
						<Button color='primary' onPress={handleSend}>
							Gửi KH &amp; Kế toán kho
						</Button>
					</div>
					<p className='text-sm text-default-500 italic'>
						Tổng hợp đơn hàng của tất cả các khách hàng đặt hàng trong ngày
					</p>
				</CardHeader>
				<CardBody className='flex flex-col gap-6'>
					<Input
						type='date'
						label='Ngày tổng hợp đơn'
						value={dateValue}
						onValueChange={setDateValue}
						className='max-w-xs'
					/>

					{error && (
						<p className='text-danger text-sm'>
							{(error as { message?: string })?.message ??
								'Không tải được tổng hợp đơn hàng.'}
						</p>
					)}
					{isLoading ? (
						<div className='flex justify-center py-8'>
							<Spinner />
						</div>
					) : (
						<Table aria-label='Bảng tổng hợp đơn đặt hàng'>
							<TableHeader>
								<TableColumn width={50}>STT</TableColumn>
								<TableColumn>Mã SP</TableColumn>
								<TableColumn>Tên sản phẩm</TableColumn>
								<TableColumn>Quy cách</TableColumn>
								<TableColumn>Dạng</TableColumn>
								<TableColumn>Dạng đóng gói</TableColumn>
								<TableColumn align='end'>Số</TableColumn>
							</TableHeader>
							<TableBody>
								{rows.length === 0 ? (
									<TableRow>
										<TableCell
											colSpan={7}
											className='text-center text-default-500'
										>
											Không có đơn hàng trong ngày {formatDisplayDate(dateValue)}.
										</TableCell>
									</TableRow>
								) : (
									rows.map(row => (
										<TableRow key={`${row.productCode}-${row.stt}`}>
											<TableCell>{row.stt}</TableCell>
											<TableCell className='font-medium'>
												{row.productCode}
											</TableCell>
											<TableCell>{row.productName}</TableCell>
											<TableCell>{row.specification}</TableCell>
											<TableCell>{row.form}</TableCell>
											<TableCell>{row.packaging}</TableCell>
											<TableCell className='text-right font-semibold'>
												{row.totalQuantity.toLocaleString()}
											</TableCell>
										</TableRow>
									))
								)}
							</TableBody>
						</Table>
					)}

					<div className='rounded-medium border border-primary/20 bg-primary/5 p-3'>
						<p className='text-sm text-primary-700'>
							Dựa vào mã SP mình sẽ tổng hợp từ từng Đơn hàng của mỗi Khách vào
							Bảng này. Bảng Tổng hợp đơn hàng này phải làm hàng ngày.
						</p>
					</div>

					<Divider />

					<div className='grid grid-cols-2 gap-4 text-center text-sm text-default-500'>
						<div>
							<p className='font-medium text-foreground'>
								Nhân viên phòng Kinh doanh
							</p>
							<p className='italic'>Ký số</p>
						</div>
						<div>
							<p className='font-medium text-foreground'>
								Trưởng phòng Kinh doanh <span className='italic'>(Duyệt)</span>
							</p>
							<p className='italic'>Ký số</p>
						</div>
					</div>
				</CardBody>
			</Card>
		</div>
	)
}

export default OrderSummaryPage
