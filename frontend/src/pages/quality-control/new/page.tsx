import React, { useCallback, useState } from 'react'
import { useNavigate } from 'react-router'
import {
	Button,
	Card,
	CardBody,
	CardHeader,
	Input,
	Select,
	SelectItem,
	Table,
	TableBody,
	TableCell,
	TableColumn,
	TableHeader,
	TableRow,
	Textarea,
} from '@heroui/react'

interface QCRow {
	key: string
	testParameter: string
	specification: string
	result: string
	passed: boolean | null
}

const EMPTY_ROW: Omit<QCRow, 'key'> = {
	testParameter: '',
	specification: '',
	result: '',
	passed: null,
}

const CHECK_TYPES = [
	{ key: 'FinalProduct', label: 'Thành phẩm' },
	{ key: 'InProcess', label: 'Bán thành phẩm' },
	{ key: 'RawMaterial', label: 'Nguyên vật liệu' },
	{ key: 'Stability', label: 'Độ ổn định' },
]

const MOCK_PRODUCTION_ORDERS = [
	{
		id: '1',
		orderNumber: 'LSX-20260221-001',
		productName: 'Amox 10%',
		lotNumber: 'LOT-2026-010',
	},
	{
		id: '2',
		orderNumber: 'LSX-20260220-001',
		productName: 'Ampi 20%',
		lotNumber: 'LOT-2026-009',
	},
]

/** Tạo phiếu kiểm tra chất lượng – GMP Module */
const NewQCCheckPage = (): React.JSX.Element => {
	const navigate = useNavigate()
	const [selectedOrder, setSelectedOrder] = useState('')
	const [checkType, setCheckType] = useState('')
	const [notes, setNotes] = useState('')
	const [rows, setRows] = useState<QCRow[]>([])

	const selectedOrderData = MOCK_PRODUCTION_ORDERS.find(
		o => o.id === selectedOrder
	)

	const addRow = useCallback(() => {
		setRows(prev => [
			...prev,
			{ ...EMPTY_ROW, key: `row-${Date.now()}-${prev.length}` },
		])
	}, [])

	const updateRow = useCallback((key: string, patch: Partial<QCRow>) => {
		setRows(prev => prev.map(r => (r.key === key ? { ...r, ...patch } : r)))
	}, [])

	const removeRow = useCallback((key: string) => {
		setRows(prev => prev.filter(r => r.key !== key))
	}, [])

	const canSave =
		!!selectedOrder &&
		!!checkType &&
		rows.length > 0 &&
		rows.every(r => r.testParameter && r.specification)

	const handleSave = () => {
		// TODO: Call API to create QC check
		navigate('/quality-control', { replace: true })
	}

	return (
		<div className='p-6 max-w-5xl'>
			<Card>
				<CardHeader>
					<h1 className='text-xl font-semibold'>
						Phiếu kiểm tra chất lượng (KCS)
					</h1>
				</CardHeader>
				<CardBody className='flex flex-col gap-6'>
					<div className='grid grid-cols-1 sm:grid-cols-2 gap-4'>
						<Select
							label='Lệnh sản xuất'
							placeholder='Chọn lệnh SX...'
							selectedKeys={selectedOrder ? [selectedOrder] : []}
							onSelectionChange={keys => {
								const val = Array.from(keys)[0] as string
								setSelectedOrder(val ?? '')
							}}
						>
							{MOCK_PRODUCTION_ORDERS.map(o => (
								<SelectItem key={o.id}>
									{o.orderNumber} — {o.productName}
								</SelectItem>
							))}
						</Select>
						<Select
							label='Loại kiểm tra'
							placeholder='Chọn loại...'
							selectedKeys={checkType ? [checkType] : []}
							onSelectionChange={keys => {
								const val = Array.from(keys)[0] as string
								setCheckType(val ?? '')
							}}
						>
							{CHECK_TYPES.map(t => (
								<SelectItem key={t.key}>{t.label}</SelectItem>
							))}
						</Select>
					</div>

					{selectedOrderData && (
						<div className='grid grid-cols-1 sm:grid-cols-3 gap-4'>
							<Input
								label='Sản phẩm'
								value={selectedOrderData.productName}
								isReadOnly
							/>
							<Input
								label='Số lô'
								value={selectedOrderData.lotNumber}
								isReadOnly
							/>
							<Input
								label='Lệnh SX'
								value={selectedOrderData.orderNumber}
								isReadOnly
							/>
						</div>
					)}

					<Textarea
						label='Ghi chú'
						placeholder='Ghi chú kiểm tra...'
						value={notes}
						onValueChange={setNotes}
						minRows={2}
					/>

					<div className='flex items-center justify-between gap-4 flex-wrap'>
						<h2 className='text-lg font-medium'>Các chỉ tiêu kiểm tra</h2>
						<Button color='primary' onPress={addRow}>
							Thêm chỉ tiêu
						</Button>
					</div>

					{rows.length > 0 && (
						<Table aria-label='Chỉ tiêu kiểm tra'>
							<TableHeader>
								<TableColumn width={40}>STT</TableColumn>
								<TableColumn>Chỉ tiêu</TableColumn>
								<TableColumn>Tiêu chuẩn</TableColumn>
								<TableColumn>Kết quả</TableColumn>
								<TableColumn width={100}>Đạt/Không</TableColumn>
								<TableColumn width={60} align='center'>
									Xóa
								</TableColumn>
							</TableHeader>
							<TableBody>
								{rows.map((row, idx) => (
									<TableRow key={row.key}>
										<TableCell>{idx + 1}</TableCell>
										<TableCell>
											<Input
												size='sm'
												placeholder='Tên chỉ tiêu'
												value={row.testParameter}
												onValueChange={v =>
													updateRow(row.key, { testParameter: v })
												}
											/>
										</TableCell>
										<TableCell>
											<Input
												size='sm'
												placeholder='Tiêu chuẩn'
												value={row.specification}
												onValueChange={v =>
													updateRow(row.key, { specification: v })
												}
											/>
										</TableCell>
										<TableCell>
											<Input
												size='sm'
												placeholder='Kết quả'
												value={row.result}
												onValueChange={v => updateRow(row.key, { result: v })}
											/>
										</TableCell>
										<TableCell>
											<Select
												size='sm'
												placeholder='—'
												selectedKeys={
													row.passed === null
														? []
														: [row.passed ? 'pass' : 'fail']
												}
												onSelectionChange={keys => {
													const val = Array.from(keys)[0] as string
													updateRow(row.key, { passed: val === 'pass' })
												}}
											>
												<SelectItem key='pass'>Đạt</SelectItem>
												<SelectItem key='fail'>Không đạt</SelectItem>
											</Select>
										</TableCell>
										<TableCell className='text-center'>
											<Button
												size='sm'
												variant='light'
												color='danger'
												onPress={() => removeRow(row.key)}
											>
												Xóa
											</Button>
										</TableCell>
									</TableRow>
								))}
							</TableBody>
						</Table>
					)}

					<div className='flex justify-end gap-2 pt-4'>
						<Button variant='flat' onPress={() => navigate('/quality-control')}>
							Hủy
						</Button>
						<Button color='primary' isDisabled={!canSave} onPress={handleSave}>
							Lưu phiếu KCS
						</Button>
					</div>
				</CardBody>
			</Card>
		</div>
	)
}

export default NewQCCheckPage
