import React, { useMemo, useState } from 'react'
import {
	Button,
	Card,
	CardBody,
	CardHeader,
	Divider,
	Input,
	Table,
	TableBody,
	TableCell,
	TableColumn,
	TableHeader,
	TableRow,
} from '@heroui/react'

interface AggregatedProduct {
	productCode: string
	productName: string
	specification: string
	type: string
	packaging: string
	totalQuantity: number
}

interface RawOrderItem {
	orderNumber: string
	customerCode: string
	customerName: string
	productCode: string
	productName: string
	specification: string
	type: string
	packaging: string
	quantity: number
}

const MOCK_ORDER_ITEMS: RawOrderItem[] = [
	{
		orderNumber: 'DH20260221-001',
		customerCode: '1111',
		customerName: 'AAAA',
		productCode: '111',
		productName: 'Amox 10%',
		specification: '100gr',
		type: 'Bột uống',
		packaging: 'Gói',
		quantity: 1000,
	},
	{
		orderNumber: 'DH20260221-001',
		customerCode: '1111',
		customerName: 'AAAA',
		productCode: '222',
		productName: 'Ampi 20%',
		specification: '250gr',
		type: 'Bột uống',
		packaging: 'Gói',
		quantity: 500,
	},
	{
		orderNumber: 'DH20260221-002',
		customerCode: '2222',
		customerName: 'BBBB',
		productCode: '111',
		productName: 'Amox 10%',
		specification: '100gr',
		type: 'Bột uống',
		packaging: 'Gói',
		quantity: 1000,
	},
	{
		orderNumber: 'DH20260221-002',
		customerCode: '2222',
		customerName: 'BBBB',
		productCode: '333',
		productName: 'Enro 10%',
		specification: '100ml',
		type: 'Dung dịch',
		packaging: 'Chai',
		quantity: 5000,
	},
	{
		orderNumber: 'DH20260221-003',
		customerCode: '3333',
		customerName: 'CCCC',
		productCode: '222',
		productName: 'Ampi 20%',
		specification: '250gr',
		type: 'Bột uống',
		packaging: 'Gói',
		quantity: 2500,
	},
	{
		orderNumber: 'DH20260221-003',
		customerCode: '3333',
		customerName: 'CCCC',
		productCode: '444',
		productName: 'Flor 30%',
		specification: '1000 ml',
		type: 'Dung dịch',
		packaging: 'Chai',
		quantity: 800,
	},
	{
		orderNumber: 'DH20260221-004',
		customerCode: '4444',
		customerName: 'DDDD',
		productCode: '555',
		productName: 'Amox hỗn dịch 15%',
		specification: '100ml',
		type: 'Hỗn dịch',
		packaging: 'Chai',
		quantity: 3500,
	},
	{
		orderNumber: 'DH20260221-004',
		customerCode: '4444',
		customerName: 'DDDD',
		productCode: '666',
		productName: 'Cetriason',
		specification: '100ml',
		type: 'Bột pha',
		packaging: 'Chai',
		quantity: 500,
	},
]

function todayFormatted(): string {
	const now = new Date()
	const d = now.getDate().toString().padStart(2, '0')
	const m = (now.getMonth() + 1).toString().padStart(2, '0')
	const y = now.getFullYear()
	return `${d}/${m}/${y}`
}

/** Bảng tổng hợp đơn đặt hàng – Sale Admin / NV phòng Kinh doanh */
const OrderSummaryPage = (): React.JSX.Element => {
	const [summaryDate] = useState(todayFormatted)

	const aggregated = useMemo<AggregatedProduct[]>(() => {
		const map = new Map<string, AggregatedProduct>()
		for (const item of MOCK_ORDER_ITEMS) {
			const existing = map.get(item.productCode)
			if (existing) {
				existing.totalQuantity += item.quantity
			} else {
				map.set(item.productCode, {
					productCode: item.productCode,
					productName: item.productName,
					specification: item.specification,
					type: item.type,
					packaging: item.packaging,
					totalQuantity: item.quantity,
				})
			}
		}
		return Array.from(map.values())
	}, [])

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
						label='Ngày tổng hợp đơn'
						value={summaryDate}
						isReadOnly
						className='max-w-xs'
					/>

					<Table aria-label='Bảng tổng hợp đơn đặt hàng'>
						<TableHeader>
							<TableColumn width={50}>STT</TableColumn>
							<TableColumn>Mã SP</TableColumn>
							<TableColumn>Tên sản phẩm</TableColumn>
							<TableColumn>Quy cách</TableColumn>
							<TableColumn>Dạng</TableColumn>
							<TableColumn>Dạng</TableColumn>
							<TableColumn align='end'>Số</TableColumn>
						</TableHeader>
						<TableBody>
							{aggregated.length === 0 ? (
								<TableRow>
									<TableCell
										colSpan={7}
										className='text-center text-default-500'
									>
										Không có đơn hàng trong ngày.
									</TableCell>
								</TableRow>
							) : (
								aggregated.map((row, idx) => (
									<TableRow key={row.productCode}>
										<TableCell>{idx + 1}</TableCell>
										<TableCell className='font-medium'>
											{row.productCode}
										</TableCell>
										<TableCell>{row.productName}</TableCell>
										<TableCell>{row.specification}</TableCell>
										<TableCell>{row.type}</TableCell>
										<TableCell>{row.packaging}</TableCell>
										<TableCell className='text-right font-semibold'>
											{row.totalQuantity.toLocaleString()}
										</TableCell>
									</TableRow>
								))
							)}
						</TableBody>
					</Table>

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
