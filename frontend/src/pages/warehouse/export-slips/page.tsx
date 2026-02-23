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
import type { ExportSlipStatus } from '../../../services/Warehouse/types'

const SLIPS_NEW_PATH = '/warehouse/export-slips/new'

const STATUS_MAP: Record<
	ExportSlipStatus,
	{
		label: string
		color: 'default' | 'primary' | 'warning' | 'success' | 'danger'
	}
> = {
	Draft: { label: 'Nháp', color: 'default' },
	PendingApproval: { label: 'Chờ duyệt', color: 'warning' },
	Approved: { label: 'Đã duyệt', color: 'primary' },
	Exported: { label: 'Đã xuất', color: 'success' },
	Cancelled: { label: 'Đã hủy', color: 'danger' },
}

const MOCK_SLIPS = [
	{
		id: '1',
		slipNumber: 'PXKTP-20260221-001',
		orderNumber: 'DH20260221-001',
		customerCode: '1111',
		customerName: 'AAAA',
		status: 'Draft' as ExportSlipStatus,
		itemCount: 6,
		createdAt: '2026-02-21',
	},
	{
		id: '2',
		slipNumber: 'PXKTP-20260220-001',
		orderNumber: 'DH20260220-001',
		customerCode: '2222',
		customerName: 'BBBB',
		status: 'Approved' as ExportSlipStatus,
		itemCount: 3,
		createdAt: '2026-02-20',
	},
	{
		id: '3',
		slipNumber: 'PXKTP-20260219-001',
		orderNumber: 'DH20260219-001',
		customerCode: '3333',
		customerName: 'CCCC',
		status: 'Exported' as ExportSlipStatus,
		itemCount: 4,
		createdAt: '2026-02-19',
	},
]

/** Danh sách phiếu xuất kho thành phẩm – GMP Module */
const ExportSlipListPage = (): React.JSX.Element => {
	return (
		<div className='p-6'>
			<Card>
				<CardHeader className='flex flex-row items-center justify-between gap-4 flex-wrap'>
					<h1 className='text-xl font-semibold'>Phiếu xuất kho thành phẩm</h1>
					<Button
						as={Link}
						to={SLIPS_NEW_PATH}
						color='primary'
						className='shrink-0'
					>
						Lập phiếu xuất kho
					</Button>
				</CardHeader>
				<CardBody>
					<p className='text-sm text-default-500 mb-4'>
						Nguyên tắc: Tồn kho thành phẩm phải đủ hàng mới cho xuất kho. Mỗi
						đơn hàng tạo 1 phiếu xuất kho.
					</p>
					<Table aria-label='Danh sách phiếu xuất kho'>
						<TableHeader>
							<TableColumn>Số phiếu XK</TableColumn>
							<TableColumn>Số đơn hàng</TableColumn>
							<TableColumn>Mã KH</TableColumn>
							<TableColumn>Tên KH</TableColumn>
							<TableColumn>Số SP</TableColumn>
							<TableColumn>Ngày tạo</TableColumn>
							<TableColumn>Trạng thái</TableColumn>
							<TableColumn align='center'>Thao tác</TableColumn>
						</TableHeader>
						<TableBody>
							{MOCK_SLIPS.length === 0 ? (
								<TableRow>
									<TableCell
										colSpan={8}
										className='text-center text-default-500'
									>
										Chưa có phiếu xuất kho.
									</TableCell>
								</TableRow>
							) : (
								MOCK_SLIPS.map(slip => {
									const st = STATUS_MAP[slip.status]
									return (
										<TableRow key={slip.id}>
											<TableCell className='font-medium'>
												{slip.slipNumber}
											</TableCell>
											<TableCell>{slip.orderNumber}</TableCell>
											<TableCell>{slip.customerCode}</TableCell>
											<TableCell>{slip.customerName}</TableCell>
											<TableCell>{slip.itemCount} SP</TableCell>
											<TableCell>{slip.createdAt}</TableCell>
											<TableCell>
												<Chip size='sm' color={st.color} variant='flat'>
													{st.label}
												</Chip>
											</TableCell>
											<TableCell className='text-center'>
												<Button size='sm' variant='light' color='primary'>
													Chi tiết
												</Button>
												{slip.status === 'Draft' && (
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

export default ExportSlipListPage
