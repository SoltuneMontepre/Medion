import React from 'react'
import { Link } from 'react-router'
import {
	Button,
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
import type { ProductionOrderStatus } from '../../services/Production/types'

const ORDERS_NEW_PATH = '/production-orders/new'

const STATUS_MAP: Record<
	ProductionOrderStatus,
	{
		label: string
		color:
			| 'default'
			| 'primary'
			| 'warning'
			| 'success'
			| 'danger'
			| 'secondary'
	}
> = {
	Pending: { label: 'Chờ SX', color: 'default' },
	InProgress: { label: 'Đang SX', color: 'warning' },
	QCPending: { label: 'Chờ KCS', color: 'secondary' },
	QCPassed: { label: 'KCS đạt', color: 'success' },
	QCFailed: { label: 'KCS không đạt', color: 'danger' },
	Completed: { label: 'Hoàn thành', color: 'success' },
	Cancelled: { label: 'Đã hủy', color: 'danger' },
}

const MOCK_ORDERS = [
	{
		id: '1',
		orderNumber: 'LSX-20260221-001',
		planNumber: 'KHSX-20260221-001',
		lotNumber: 'LOT-2026-010',
		status: 'Pending' as ProductionOrderStatus,
		itemCount: 3,
		createdAt: '2026-02-21',
	},
	{
		id: '2',
		orderNumber: 'LSX-20260220-001',
		planNumber: 'KHSX-20260220-001',
		lotNumber: 'LOT-2026-009',
		status: 'InProgress' as ProductionOrderStatus,
		itemCount: 2,
		createdAt: '2026-02-20',
	},
	{
		id: '3',
		orderNumber: 'LSX-20260219-001',
		planNumber: 'KHSX-20260219-001',
		lotNumber: 'LOT-2026-008',
		status: 'QCPending' as ProductionOrderStatus,
		itemCount: 4,
		createdAt: '2026-02-19',
	},
	{
		id: '4',
		orderNumber: 'LSX-20260218-001',
		planNumber: 'KHSX-20260218-001',
		lotNumber: 'LOT-2026-007',
		status: 'Completed' as ProductionOrderStatus,
		itemCount: 5,
		createdAt: '2026-02-18',
	},
]

/** Danh sách lệnh sản xuất – GMP Module */
const ProductionOrderListPage = (): React.JSX.Element => {
	return (
		<div className='p-6'>
			<Card>
				<CardHeader className='flex flex-row items-center justify-between gap-4 flex-wrap'>
					<h1 className='text-xl font-semibold'>Lệnh sản xuất</h1>
					<Button
						as={Link}
						to={ORDERS_NEW_PATH}
						color='primary'
						className='shrink-0'
					>
						Tạo lệnh SX
					</Button>
				</CardHeader>
				<CardBody>
					<Table aria-label='Danh sách lệnh sản xuất'>
						<TableHeader>
							<TableColumn>Số lệnh SX</TableColumn>
							<TableColumn>Số KHSX</TableColumn>
							<TableColumn>Số lô</TableColumn>
							<TableColumn>Số SP</TableColumn>
							<TableColumn>Ngày tạo</TableColumn>
							<TableColumn>Trạng thái</TableColumn>
							<TableColumn align='center'>Thao tác</TableColumn>
						</TableHeader>
						<TableBody>
							{MOCK_ORDERS.length === 0 ? (
								<TableRow>
									<TableCell
										colSpan={7}
										className='text-center text-default-500'
									>
										Chưa có lệnh sản xuất.
									</TableCell>
								</TableRow>
							) : (
								MOCK_ORDERS.map(order => {
									const st = STATUS_MAP[order.status]
									return (
										<TableRow key={order.id}>
											<TableCell className='font-medium'>
												{order.orderNumber}
											</TableCell>
											<TableCell>{order.planNumber}</TableCell>
											<TableCell>{order.lotNumber}</TableCell>
											<TableCell>{order.itemCount} SP</TableCell>
											<TableCell>{order.createdAt}</TableCell>
											<TableCell>
												<Chip size='sm' color={st.color} variant='flat'>
													{st.label}
												</Chip>
											</TableCell>
											<TableCell className='text-center'>
												<Button size='sm' variant='light' color='primary'>
													Chi tiết
												</Button>
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

export default ProductionOrderListPage
