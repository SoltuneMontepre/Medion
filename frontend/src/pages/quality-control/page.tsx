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
import type { QCCheckStatus } from '../../services/QualityControl/types'

const QC_NEW_PATH = '/quality-control/new'

const STATUS_MAP: Record<
	QCCheckStatus,
	{
		label: string
		color: 'default' | 'primary' | 'warning' | 'success' | 'danger'
	}
> = {
	Pending: { label: 'Chờ kiểm', color: 'default' },
	InProgress: { label: 'Đang kiểm', color: 'warning' },
	Passed: { label: 'Đạt', color: 'success' },
	Failed: { label: 'Không đạt', color: 'danger' },
	ConditionalPass: { label: 'Đạt có ĐK', color: 'primary' },
}

const MOCK_CHECKS = [
	{
		id: '1',
		checkNumber: 'KCS-20260221-001',
		productionOrderNumber: 'LSX-20260221-001',
		productName: 'Amox 10%',
		lotNumber: 'LOT-2026-010',
		checkType: 'FinalProduct',
		status: 'Pending' as QCCheckStatus,
		checkedBy: null,
	},
	{
		id: '2',
		checkNumber: 'KCS-20260220-001',
		productionOrderNumber: 'LSX-20260220-001',
		productName: 'Ampi 20%',
		lotNumber: 'LOT-2026-009',
		checkType: 'FinalProduct',
		status: 'Passed' as QCCheckStatus,
		checkedBy: 'NV KCS',
	},
	{
		id: '3',
		checkNumber: 'KCS-20260219-001',
		productionOrderNumber: 'LSX-20260219-001',
		productName: 'Enro 10%',
		lotNumber: 'LOT-2026-008',
		checkType: 'InProcess',
		status: 'Failed' as QCCheckStatus,
		checkedBy: 'NV KCS',
	},
]

/** Kiểm tra chất lượng (KCS) – GMP Module */
const QualityControlListPage = (): React.JSX.Element => {
	return (
		<div className='p-6'>
			<Card>
				<CardHeader className='flex flex-row items-center justify-between gap-4 flex-wrap'>
					<h1 className='text-xl font-semibold'>Kiểm tra chất lượng (KCS)</h1>
					<Button
						as={Link}
						to={QC_NEW_PATH}
						color='primary'
						className='shrink-0'
					>
						Tạo phiếu KCS
					</Button>
				</CardHeader>
				<CardBody>
					<Table aria-label='Danh sách kiểm tra chất lượng'>
						<TableHeader>
							<TableColumn>Số phiếu KCS</TableColumn>
							<TableColumn>Lệnh SX</TableColumn>
							<TableColumn>Sản phẩm</TableColumn>
							<TableColumn>Số lô</TableColumn>
							<TableColumn>Loại kiểm tra</TableColumn>
							<TableColumn>Người kiểm</TableColumn>
							<TableColumn>Kết quả</TableColumn>
							<TableColumn align='center'>Thao tác</TableColumn>
						</TableHeader>
						<TableBody>
							{MOCK_CHECKS.length === 0 ? (
								<TableRow>
									<TableCell
										colSpan={8}
										className='text-center text-default-500'
									>
										Chưa có phiếu kiểm tra chất lượng.
									</TableCell>
								</TableRow>
							) : (
								MOCK_CHECKS.map(check => {
									const st = STATUS_MAP[check.status]
									return (
										<TableRow key={check.id}>
											<TableCell className='font-medium'>
												{check.checkNumber}
											</TableCell>
											<TableCell>{check.productionOrderNumber}</TableCell>
											<TableCell>{check.productName}</TableCell>
											<TableCell>{check.lotNumber}</TableCell>
											<TableCell>
												{check.checkType === 'FinalProduct'
													? 'Thành phẩm'
													: 'Bán thành phẩm'}
											</TableCell>
											<TableCell>{check.checkedBy ?? '—'}</TableCell>
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

export default QualityControlListPage
