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
import type { ProductionPlanStatus } from '../../services/Production/types'

const PLANS_NEW_PATH = '/production-plans/new'

const STATUS_MAP: Record<
	ProductionPlanStatus,
	{
		label: string
		color: 'default' | 'primary' | 'warning' | 'success' | 'danger'
	}
> = {
	Draft: { label: 'Nháp', color: 'default' },
	Approved: { label: 'Đã duyệt', color: 'primary' },
	InProgress: { label: 'Đang SX', color: 'warning' },
	Completed: { label: 'Hoàn thành', color: 'success' },
	Cancelled: { label: 'Đã hủy', color: 'danger' },
}

const MOCK_PLANS = [
	{
		id: '1',
		planNumber: 'KHSX-20260221-001',
		planDate: '2026-02-21',
		status: 'Draft' as ProductionPlanStatus,
		itemCount: 6,
		createdBy: 'NV Kế hoạch',
	},
	{
		id: '2',
		planNumber: 'KHSX-20260220-001',
		planDate: '2026-02-20',
		status: 'Approved' as ProductionPlanStatus,
		itemCount: 4,
		createdBy: 'NV Kế hoạch',
	},
	{
		id: '3',
		planNumber: 'KHSX-20260219-001',
		planDate: '2026-02-19',
		status: 'Completed' as ProductionPlanStatus,
		itemCount: 5,
		createdBy: 'NV Kế hoạch',
	},
]

/** Danh sách kế hoạch sản xuất – GMP Module */
const ProductionPlanListPage = (): React.JSX.Element => {
	return (
		<div className='p-6'>
			<Card>
				<CardHeader className='flex flex-row items-center justify-between gap-4 flex-wrap'>
					<h1 className='text-xl font-semibold'>Kế hoạch sản xuất</h1>
					<Button
						as={Link}
						to={PLANS_NEW_PATH}
						color='primary'
						className='shrink-0'
					>
						Lập kế hoạch SX
					</Button>
				</CardHeader>
				<CardBody>
					<Table aria-label='Danh sách kế hoạch sản xuất'>
						<TableHeader>
							<TableColumn>Số KHSX</TableColumn>
							<TableColumn>Ngày lập</TableColumn>
							<TableColumn>Số SP</TableColumn>
							<TableColumn>Người lập</TableColumn>
							<TableColumn>Trạng thái</TableColumn>
							<TableColumn align='center'>Thao tác</TableColumn>
						</TableHeader>
						<TableBody>
							{MOCK_PLANS.length === 0 ? (
								<TableRow>
									<TableCell
										colSpan={6}
										className='text-center text-default-500'
									>
										Chưa có kế hoạch sản xuất. Nhấn &quot;Lập kế hoạch SX&quot;
										để tạo mới.
									</TableCell>
								</TableRow>
							) : (
								MOCK_PLANS.map(plan => {
									const st = STATUS_MAP[plan.status]
									return (
										<TableRow key={plan.id}>
											<TableCell className='font-medium'>
												{plan.planNumber}
											</TableCell>
											<TableCell>{plan.planDate}</TableCell>
											<TableCell>{plan.itemCount} sản phẩm</TableCell>
											<TableCell>{plan.createdBy}</TableCell>
											<TableCell>
												<Chip size='sm' color={st.color} variant='flat'>
													{st.label}
												</Chip>
											</TableCell>
											<TableCell className='text-center'>
												<Button size='sm' variant='light' color='primary'>
													Chi tiết
												</Button>
												{plan.status === 'Draft' && (
													<Button size='sm' variant='light' color='success'>
														Duyệt
													</Button>
												)}
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

export default ProductionPlanListPage
