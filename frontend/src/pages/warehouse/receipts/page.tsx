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
import type { ReceiptStatus } from '../../../services/Warehouse/types'

const STATUS_MAP: Record<
	ReceiptStatus,
	{ label: string; color: 'default' | 'success' | 'danger' }
> = {
	Draft: { label: 'Nháp', color: 'default' },
	Confirmed: { label: 'Đã xác nhận', color: 'success' },
	Cancelled: { label: 'Đã hủy', color: 'danger' },
}

const MOCK_RECEIPTS = [
	{
		id: '1',
		receiptNumber: 'NKTP-20260221-001',
		productionOrderNumber: 'LSX-20260220-001',
		productName: 'Ampi 20%',
		lotNumber: 'LOT-2026-009',
		quantity: 2000,
		status: 'Confirmed' as ReceiptStatus,
		confirmedBy: 'Thủ kho',
		createdAt: '2026-02-21',
	},
	{
		id: '2',
		receiptNumber: 'NKTP-20260220-001',
		productionOrderNumber: 'LSX-20260219-001',
		productName: 'Enro 10%',
		lotNumber: 'LOT-2026-008',
		quantity: 3500,
		status: 'Draft' as ReceiptStatus,
		confirmedBy: null,
		createdAt: '2026-02-20',
	},
	{
		id: '3',
		receiptNumber: 'NKTP-20260219-001',
		productionOrderNumber: 'LSX-20260218-001',
		productName: 'Flor 30%',
		lotNumber: 'LOT-2026-007',
		quantity: 200,
		status: 'Confirmed' as ReceiptStatus,
		confirmedBy: 'Thủ kho',
		createdAt: '2026-02-19',
	},
]

/** Nhập kho thành phẩm – GMP Module (sau khi KCS đạt) */
const WarehouseReceiptListPage = (): React.JSX.Element => {
	return (
		<div className='p-6'>
			<Card>
				<CardHeader>
					<h1 className='text-xl font-semibold'>Nhập kho thành phẩm</h1>
				</CardHeader>
				<CardBody>
					<p className='text-sm text-default-500 mb-4'>
						Sau khi sản phẩm qua KCS đạt yêu cầu, tiến hành nhập kho thành phẩm.
					</p>
					<Table aria-label='Danh sách phiếu nhập kho'>
						<TableHeader>
							<TableColumn>Số phiếu NK</TableColumn>
							<TableColumn>Lệnh SX</TableColumn>
							<TableColumn>Sản phẩm</TableColumn>
							<TableColumn>Số lô</TableColumn>
							<TableColumn align='end'>Số lượng</TableColumn>
							<TableColumn>Người xác nhận</TableColumn>
							<TableColumn>Ngày tạo</TableColumn>
							<TableColumn>Trạng thái</TableColumn>
						</TableHeader>
						<TableBody>
							{MOCK_RECEIPTS.length === 0 ? (
								<TableRow>
									<TableCell
										colSpan={8}
										className='text-center text-default-500'
									>
										Chưa có phiếu nhập kho.
									</TableCell>
								</TableRow>
							) : (
								MOCK_RECEIPTS.map(receipt => {
									const st = STATUS_MAP[receipt.status]
									return (
										<TableRow key={receipt.id}>
											<TableCell className='font-medium'>
												{receipt.receiptNumber}
											</TableCell>
											<TableCell>{receipt.productionOrderNumber}</TableCell>
											<TableCell>{receipt.productName}</TableCell>
											<TableCell>{receipt.lotNumber}</TableCell>
											<TableCell className='text-right font-medium'>
												{receipt.quantity.toLocaleString()}
											</TableCell>
											<TableCell>{receipt.confirmedBy ?? '—'}</TableCell>
											<TableCell>{receipt.createdAt}</TableCell>
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

export default WarehouseReceiptListPage
