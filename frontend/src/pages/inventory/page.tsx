import React, { useState } from 'react'
import {
	Button,
	Card,
	CardBody,
	CardHeader,
	Chip,
	Input,
	Tab,
	Table,
	TableBody,
	TableCell,
	TableColumn,
	TableHeader,
	TableRow,
	Tabs,
} from '@heroui/react'

const MOCK_INVENTORY = [
	{
		id: '1',
		productCode: '111',
		productName: 'Amox 10%',
		specification: '100gr',
		type: 'Bột uống',
		packaging: 'Gói',
		lotNumber: 'LOT-2026-001',
		quantity: 500,
		manufacturingDate: '2026-01-15',
		expiryDate: '2028-01-15',
	},
	{
		id: '2',
		productCode: '222',
		productName: 'Ampi 20%',
		specification: '250gr',
		type: 'Bột uống',
		packaging: 'Gói',
		lotNumber: 'LOT-2026-002',
		quantity: 300,
		manufacturingDate: '2026-01-20',
		expiryDate: '2028-01-20',
	},
	{
		id: '3',
		productCode: '333',
		productName: 'Enro 10%',
		specification: '100ml',
		type: 'Dung dịch',
		packaging: 'Chai',
		lotNumber: 'LOT-2026-003',
		quantity: 150,
		manufacturingDate: '2026-02-01',
		expiryDate: '2028-02-01',
	},
]

/** Tồn kho thành phẩm – GMP Module */
const InventoryPage = (): React.JSX.Element => {
	const [searchTerm, setSearchTerm] = useState('')

	const filtered = MOCK_INVENTORY.filter(
		item =>
			item.productCode.toLowerCase().includes(searchTerm.toLowerCase()) ||
			item.productName.toLowerCase().includes(searchTerm.toLowerCase()) ||
			item.lotNumber.toLowerCase().includes(searchTerm.toLowerCase())
	)

	return (
		<div className='p-6'>
			<Card>
				<CardHeader className='flex flex-col gap-4'>
					<div className='flex flex-row items-center justify-between gap-4 flex-wrap w-full'>
						<h1 className='text-xl font-semibold'>Tồn kho thành phẩm</h1>
					</div>
					<Tabs aria-label='Loại tồn kho' color='primary' variant='underlined'>
						<Tab key='finished' title='Thành phẩm' />
						<Tab key='raw' title='Nguyên vật liệu' />
					</Tabs>
				</CardHeader>
				<CardBody className='flex flex-col gap-4'>
					<Input
						placeholder='Tìm theo mã SP, tên SP, số lô...'
						value={searchTerm}
						onValueChange={setSearchTerm}
						className='max-w-md'
						isClearable
						onClear={() => setSearchTerm('')}
					/>
					<Table aria-label='Tồn kho thành phẩm'>
						<TableHeader>
							<TableColumn>Mã SP</TableColumn>
							<TableColumn>Tên sản phẩm</TableColumn>
							<TableColumn>Quy cách</TableColumn>
							<TableColumn>Dạng</TableColumn>
							<TableColumn>Đóng gói</TableColumn>
							<TableColumn>Số lô</TableColumn>
							<TableColumn align='end'>Tồn kho</TableColumn>
							<TableColumn>NSX</TableColumn>
							<TableColumn>HSD</TableColumn>
							<TableColumn>Trạng thái</TableColumn>
						</TableHeader>
						<TableBody>
							{filtered.length === 0 ? (
								<TableRow>
									<TableCell
										colSpan={10}
										className='text-center text-default-500'
									>
										Không tìm thấy dữ liệu tồn kho.
									</TableCell>
								</TableRow>
							) : (
								filtered.map(item => (
									<TableRow key={item.id}>
										<TableCell>{item.productCode}</TableCell>
										<TableCell>{item.productName}</TableCell>
										<TableCell>{item.specification}</TableCell>
										<TableCell>{item.type}</TableCell>
										<TableCell>{item.packaging}</TableCell>
										<TableCell>{item.lotNumber}</TableCell>
										<TableCell className='text-right font-medium'>
											{item.quantity.toLocaleString()}
										</TableCell>
										<TableCell>{item.manufacturingDate}</TableCell>
										<TableCell>{item.expiryDate}</TableCell>
										<TableCell>
											<Chip
												size='sm'
												color={item.quantity > 100 ? 'success' : 'warning'}
												variant='flat'
											>
												{item.quantity > 100 ? 'Đủ hàng' : 'Sắp hết'}
											</Chip>
										</TableCell>
									</TableRow>
								))
							)}
						</TableBody>
					</Table>
				</CardBody>
			</Card>
		</div>
	)
}

export default InventoryPage
