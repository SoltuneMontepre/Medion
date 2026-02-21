import React from 'react'
import {
	Card,
	CardBody,
	CardHeader,
	Chip,
	Table,
	TableBody,
	TableCell,
	TableColumn,
	TableHeader,
	TableRow,
} from '@heroui/react'
import type { DeliveryStatus } from '../../services/Delivery/types'

const STATUS_MAP: Record<
	DeliveryStatus,
	{
		label: string
		color: 'default' | 'primary' | 'warning' | 'success' | 'danger'
	}
> = {
	Pending: { label: 'Chờ giao', color: 'default' },
	InTransit: { label: 'Đang giao', color: 'warning' },
	Delivered: { label: 'Đã giao', color: 'success' },
	PartialDelivery: { label: 'Giao một phần', color: 'primary' },
	Returned: { label: 'Trả hàng', color: 'danger' },
	Cancelled: { label: 'Đã hủy', color: 'danger' },
}

const MOCK_DELIVERIES = [
	{
		id: '1',
		deliveryNumber: 'GH-20260221-001',
		exportSlipNumber: 'PXKTP-20260220-001',
		orderNumber: 'DH20260220-001',
		customerName: 'BBBB',
		customerAddress: 'Hà Nội',
		status: 'Pending' as DeliveryStatus,
		deliveryDate: '2026-02-22',
	},
	{
		id: '2',
		deliveryNumber: 'GH-20260220-001',
		exportSlipNumber: 'PXKTP-20260219-001',
		orderNumber: 'DH20260219-001',
		customerName: 'CCCC',
		customerAddress: 'TP.HCM',
		status: 'InTransit' as DeliveryStatus,
		deliveryDate: '2026-02-21',
	},
	{
		id: '3',
		deliveryNumber: 'GH-20260219-001',
		exportSlipNumber: 'PXKTP-20260218-001',
		orderNumber: 'DH20260218-001',
		customerName: 'DDDD',
		customerAddress: 'Đà Nẵng',
		status: 'Delivered' as DeliveryStatus,
		deliveryDate: '2026-02-20',
	},
]

/** Theo dõi giao hàng – GMP Module */
const DeliveryListPage = (): React.JSX.Element => {
	return (
		<div className='p-6'>
			<Card>
				<CardHeader>
					<h1 className='text-xl font-semibold'>Giao hàng</h1>
				</CardHeader>
				<CardBody>
					<Table aria-label='Danh sách giao hàng'>
						<TableHeader>
							<TableColumn>Số phiếu GH</TableColumn>
							<TableColumn>Phiếu XK</TableColumn>
							<TableColumn>Đơn hàng</TableColumn>
							<TableColumn>Khách hàng</TableColumn>
							<TableColumn>Địa chỉ giao</TableColumn>
							<TableColumn>Ngày giao dự kiến</TableColumn>
							<TableColumn>Trạng thái</TableColumn>
						</TableHeader>
						<TableBody>
							{MOCK_DELIVERIES.length === 0 ? (
								<TableRow>
									<TableCell
										colSpan={7}
										className='text-center text-default-500'
									>
										Chưa có đơn giao hàng.
									</TableCell>
								</TableRow>
							) : (
								MOCK_DELIVERIES.map(d => {
									const st = STATUS_MAP[d.status]
									return (
										<TableRow key={d.id}>
											<TableCell className='font-medium'>
												{d.deliveryNumber}
											</TableCell>
											<TableCell>{d.exportSlipNumber}</TableCell>
											<TableCell>{d.orderNumber}</TableCell>
											<TableCell>{d.customerName}</TableCell>
											<TableCell>{d.customerAddress}</TableCell>
											<TableCell>{d.deliveryDate}</TableCell>
											<TableCell>
												<Chip size='sm' color={st.color} variant='flat'>
													{st.label}
												</Chip>
											</TableCell>
										</TableRow>
									)
								})
							)}
						</TableBody>
					</Table>
				</CardBody>
			</Card>
		</div>
	)
}

export default DeliveryListPage
