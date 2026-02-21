import React, { useCallback, useState } from 'react'
import { useNavigate } from 'react-router'
import {
	Button,
	Card,
	CardBody,
	CardHeader,
	Divider,
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

interface MaterialRow {
	key: string
	materialCode: string
	materialName: string
	unit: string
	ratioPercent: string
	formulaPerUnit: string
	exportQuantity: string
	variance: string
	notes: string
}

const EMPTY_MATERIAL: Omit<MaterialRow, 'key'> = {
	materialCode: '',
	materialName: '',
	unit: 'kg',
	ratioPercent: '',
	formulaPerUnit: '',
	exportQuantity: '',
	variance: '',
	notes: '',
}

const MOCK_PLANS = [
	{ id: '1', planNumber: 'KHSX-20260221-001' },
	{ id: '2', planNumber: 'KHSX-20260220-001' },
]

function computeTotal(rows: MaterialRow[]): number {
	return rows.reduce((sum, r) => {
		const qty = parseFloat(r.exportQuantity)
		return sum + (Number.isNaN(qty) ? 0 : qty)
	}, 0)
}

/** Lệnh sản xuất kiêm Phiếu xuất kho vật tư – GMP Module */
const NewProductionOrderPage = (): React.JSX.Element => {
	const navigate = useNavigate()

	// Header fields
	const [selectedPlan, setSelectedPlan] = useState('')
	const [productName, setProductName] = useState('')
	const [productType, setProductType] = useState('')
	const [lotNumber, setLotNumber] = useState('')
	const [orderNumber, setOrderNumber] = useState('')
	const [manufacturingDate, setManufacturingDate] = useState('')
	const [expiryDate, setExpiryDate] = useState('')
	const [spec1, setSpec1] = useState('')
	const [quantitySpec1, setQuantitySpec1] = useState('')
	const [spec2, setSpec2] = useState('')
	const [quantitySpec2, setQuantitySpec2] = useState('')
	const [batchSize, setBatchSize] = useState('')
	const [batchUnit, setBatchUnit] = useState('lít')
	const [ph, setPh] = useState('')
	const [notes, setNotes] = useState('')

	// Raw material rows
	const [rows, setRows] = useState<MaterialRow[]>([])

	const addRow = useCallback(() => {
		setRows(prev => [
			...prev,
			{ ...EMPTY_MATERIAL, key: `row-${Date.now()}-${prev.length}` },
		])
	}, [])

	const updateRow = useCallback((key: string, patch: Partial<MaterialRow>) => {
		setRows(prev => prev.map(r => (r.key === key ? { ...r, ...patch } : r)))
	}, [])

	const removeRow = useCallback((key: string) => {
		setRows(prev => prev.filter(r => r.key !== key))
	}, [])

	const total = computeTotal(rows)

	const canSave =
		!!selectedPlan &&
		!!productName &&
		!!lotNumber &&
		!!manufacturingDate &&
		!!expiryDate &&
		!!batchSize &&
		rows.length > 0 &&
		rows.every(r => r.materialCode && r.exportQuantity)

	const handleSave = () => {
		// TODO: Call API to create production order
		navigate('/production-orders', { replace: true })
	}

	return (
		<div className='p-6 max-w-6xl'>
			<Card>
				<CardHeader>
					<h1 className='text-xl font-semibold'>
						Lệnh sản xuất kiêm Phiếu xuất kho vật tư
					</h1>
				</CardHeader>
				<CardBody className='flex flex-col gap-6'>
					{/* Plan selection */}
					<Select
						label='Kế hoạch sản xuất'
						placeholder='Chọn KHSX...'
						className='max-w-sm'
						selectedKeys={selectedPlan ? [selectedPlan] : []}
						onSelectionChange={keys => {
							const val = Array.from(keys)[0] as string
							setSelectedPlan(val ?? '')
						}}
					>
						{MOCK_PLANS.map(p => (
							<SelectItem key={p.id}>{p.planNumber}</SelectItem>
						))}
					</Select>

					<Divider />

					{/* Product info header - mirrors the document layout */}
					<div className='grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-4'>
						<div className='flex flex-col gap-4'>
							<Input
								label='Tên SP'
								placeholder='VD: FLORTYLO'
								value={productName}
								onValueChange={setProductName}
							/>
							<Input
								label='Dạng SP'
								placeholder='VD: THUỐC DUNG DỊCH TIÊM'
								value={productType}
								onValueChange={setProductType}
							/>
							<Input
								label='Số lô'
								placeholder='VD: FL12052025'
								value={lotNumber}
								onValueChange={setLotNumber}
							/>
							<Input
								label='Ngày sản xuất'
								type='date'
								value={manufacturingDate}
								onValueChange={setManufacturingDate}
							/>
							<Input
								label='Hạn sử dụng'
								type='date'
								value={expiryDate}
								onValueChange={setExpiryDate}
							/>
						</div>
						<div className='flex flex-col gap-4'>
							<div className='grid grid-cols-2 gap-4'>
								<Input
									label='Quy cách 1'
									placeholder='VD: 100 ml'
									value={spec1}
									onValueChange={setSpec1}
								/>
								<Input
									label='Số lượng QC1'
									type='number'
									placeholder='VD: 2000'
									value={quantitySpec1}
									onValueChange={setQuantitySpec1}
									endContent={
										<span className='text-default-400 text-sm'>chai</span>
									}
								/>
							</div>
							<div className='grid grid-cols-2 gap-4'>
								<Input
									label='Quy cách 2'
									placeholder='VD: 500 ml'
									value={spec2}
									onValueChange={setSpec2}
								/>
								<Input
									label='Số lượng QC2'
									type='number'
									placeholder='VD: 0'
									value={quantitySpec2}
									onValueChange={setQuantitySpec2}
									endContent={
										<span className='text-default-400 text-sm'>chai</span>
									}
								/>
							</div>
							<Input
								label='Số LSX'
								placeholder='VD: LSX15102025'
								value={orderNumber}
								onValueChange={setOrderNumber}
							/>
							<div className='grid grid-cols-2 gap-4'>
								<Input
									label='Cỡ lô'
									type='number'
									placeholder='VD: 200'
									value={batchSize}
									onValueChange={setBatchSize}
								/>
								<Select
									label='Đơn vị'
									selectedKeys={[batchUnit]}
									onSelectionChange={keys => {
										const val = Array.from(keys)[0] as string
										setBatchUnit(val ?? 'lít')
									}}
								>
									<SelectItem key='lít'>lít</SelectItem>
									<SelectItem key='kg'>kg</SelectItem>
									<SelectItem key='tấn'>tấn</SelectItem>
								</Select>
							</div>
						</div>
					</div>

					<Divider />

					{/* Raw material BOM table */}
					<div className='flex items-center justify-between gap-4 flex-wrap'>
						<h2 className='text-lg font-medium'>
							Danh sách nguyên vật liệu (BOM)
						</h2>
						<Button color='primary' onPress={addRow}>
							Thêm nguyên liệu
						</Button>
					</div>

					{rows.length > 0 && (
						<div className='overflow-x-auto'>
							<Table aria-label='Nguyên vật liệu sản xuất'>
								<TableHeader>
									<TableColumn width={40}>STT</TableColumn>
									<TableColumn>Mã NL</TableColumn>
									<TableColumn>Tên NL</TableColumn>
									<TableColumn width={70}>ĐVT</TableColumn>
									<TableColumn width={90}>Tỷ lệ %</TableColumn>
									<TableColumn width={110}>CT cho 1 lít</TableColumn>
									<TableColumn width={120}>SL xuất</TableColumn>
									<TableColumn width={90}>SL +/-</TableColumn>
									<TableColumn>Ghi chú</TableColumn>
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
													placeholder='VD: KSI01'
													value={row.materialCode}
													onValueChange={v =>
														updateRow(row.key, { materialCode: v })
													}
												/>
											</TableCell>
											<TableCell>
												<Input
													size='sm'
													placeholder='VD: FLORFENICOL'
													value={row.materialName}
													onValueChange={v =>
														updateRow(row.key, { materialName: v })
													}
												/>
											</TableCell>
											<TableCell>
												<Select
													size='sm'
													selectedKeys={[row.unit]}
													onSelectionChange={keys => {
														const val = Array.from(keys)[0] as string
														updateRow(row.key, { unit: val ?? 'kg' })
													}}
												>
													<SelectItem key='kg'>kg</SelectItem>
													<SelectItem key='g'>g</SelectItem>
													<SelectItem key='lít'>lít</SelectItem>
													<SelectItem key='ml'>ml</SelectItem>
												</Select>
											</TableCell>
											<TableCell>
												<Input
													size='sm'
													type='number'
													placeholder='%'
													value={row.ratioPercent}
													onValueChange={v =>
														updateRow(row.key, { ratioPercent: v })
													}
												/>
											</TableCell>
											<TableCell>
												<Input
													size='sm'
													type='number'
													placeholder='CT/1 lít'
													value={row.formulaPerUnit}
													onValueChange={v =>
														updateRow(row.key, { formulaPerUnit: v })
													}
												/>
											</TableCell>
											<TableCell>
												<Input
													size='sm'
													type='number'
													placeholder='SL xuất'
													value={row.exportQuantity}
													onValueChange={v =>
														updateRow(row.key, { exportQuantity: v })
													}
												/>
											</TableCell>
											<TableCell>
												<Input
													size='sm'
													type='number'
													placeholder='+/-'
													value={row.variance}
													onValueChange={v =>
														updateRow(row.key, { variance: v })
													}
												/>
											</TableCell>
											<TableCell>
												<Input
													size='sm'
													placeholder='Ghi chú'
													value={row.notes}
													onValueChange={v => updateRow(row.key, { notes: v })}
												/>
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
						</div>
					)}

					{/* Total + pH */}
					{rows.length > 0 && (
						<div className='flex items-center gap-6'>
							<div className='rounded-medium border border-divider px-4 py-2'>
								<span className='text-sm text-default-500'>TỔNG CỘNG: </span>
								<span className='font-semibold'>
									{total.toLocaleString(undefined, {
										minimumFractionDigits: 4,
										maximumFractionDigits: 4,
									})}
								</span>
							</div>
							<Input
								label='pH'
								placeholder='Giá trị pH'
								value={ph}
								onValueChange={setPh}
								className='max-w-[150px]'
							/>
						</div>
					)}

					<Textarea
						label='Ghi chú'
						placeholder='Ghi chú cho lệnh sản xuất...'
						value={notes}
						onValueChange={setNotes}
						minRows={2}
					/>

					<Divider />

					{/* Sign-off footer */}
					<div className='grid grid-cols-2 md:grid-cols-5 gap-4 text-center text-sm text-default-500'>
						<div>
							<p className='font-medium text-foreground'>Thủ kho</p>
							<p className='italic'>Ký số</p>
						</div>
						<div>
							<p className='font-medium text-foreground'>Người nhận</p>
							<p className='italic'>Ký số</p>
						</div>
						<div>
							<p className='font-medium text-foreground'>NV IPC</p>
							<p className='italic'>Ký số</p>
						</div>
						<div>
							<p className='font-medium text-foreground'>Người duyệt LSX</p>
							<p className='italic'>Ký số</p>
						</div>
						<div>
							<p className='font-medium text-foreground'>Người làm lệnh SX</p>
							<p className='italic'>Ký số</p>
						</div>
					</div>

					<div className='flex justify-end gap-2 pt-4'>
						<Button
							variant='flat'
							onPress={() => navigate('/production-orders')}
						>
							Hủy
						</Button>
						<Button color='primary' isDisabled={!canSave} onPress={handleSave}>
							Lưu lệnh SX
						</Button>
					</div>
				</CardBody>
			</Card>
		</div>
	)
}

export default NewProductionOrderPage
