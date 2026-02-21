import React, { useCallback, useState } from 'react'
import { useNavigate } from 'react-router'
import {
	Button,
	Card,
	CardBody,
	CardHeader,
	Input,
	Table,
	TableBody,
	TableCell,
	TableColumn,
	TableHeader,
	TableRow,
} from '@heroui/react'

interface SlipRow {
	key: string
	productCode: string
	productName: string
	specification: string
	type: string
	packaging: string
	quantity: string
	lotNumber: string
	manufacturingDate: string
	expiryDate: string
}

const EMPTY_ROW: Omit<SlipRow, 'key'> = {
	productCode: '',
	productName: '',
	specification: '',
	type: '',
	packaging: '',
	quantity: '',
	lotNumber: '',
	manufacturingDate: '',
	expiryDate: '',
}

/** Lập phiếu xuất kho thành phẩm mới – GMP Module */
const NewExportSlipPage = (): React.JSX.Element => {
	const navigate = useNavigate()

	const [customerCode, setCustomerCode] = useState('')
	const [customerName, setCustomerName] = useState('')
	const [customerAddress, setCustomerAddress] = useState('')
	const [customerPhone, setCustomerPhone] = useState('')
	const [orderNumber, setOrderNumber] = useState('')
	const [rows, setRows] = useState<SlipRow[]>([])

	const addRow = useCallback(() => {
		setRows(prev => [
			...prev,
			{ ...EMPTY_ROW, key: `row-${Date.now()}-${prev.length}` },
		])
	}, [])

	const updateRow = useCallback((key: string, patch: Partial<SlipRow>) => {
		setRows(prev => prev.map(r => (r.key === key ? { ...r, ...patch } : r)))
	}, [])

	const removeRow = useCallback((key: string) => {
		setRows(prev => prev.filter(r => r.key !== key))
	}, [])

	const canSave =
		!!customerCode &&
		!!orderNumber &&
		rows.length > 0 &&
		rows.every(r => r.productCode && r.quantity && r.lotNumber)

	const handleSave = () => {
		// TODO: Call API to create export slip
		navigate('/warehouse/export-slips', { replace: true })
	}

	return (
		<div className='p-6 max-w-6xl'>
			<Card>
				<CardHeader>
					<h1 className='text-xl font-semibold'>Phiếu xuất kho thành phẩm</h1>
				</CardHeader>
				<CardBody className='flex flex-col gap-6'>
					<div className='grid grid-cols-1 sm:grid-cols-2 gap-4'>
						<Input
							label='Mã khách hàng'
							placeholder='VD: 1111'
							value={customerCode}
							onValueChange={setCustomerCode}
						/>
						<Input
							label='Tên khách hàng'
							placeholder='VD: AAAA'
							value={customerName}
							onValueChange={setCustomerName}
						/>
						<Input
							label='Địa chỉ'
							value={customerAddress}
							onValueChange={setCustomerAddress}
						/>
						<Input
							label='Số điện thoại'
							value={customerPhone}
							onValueChange={setCustomerPhone}
						/>
						<Input
							label='Số đơn hàng'
							placeholder='VD: DH20260221-001'
							value={orderNumber}
							onValueChange={setOrderNumber}
						/>
					</div>

					<div className='flex items-center justify-between gap-4 flex-wrap'>
						<h2 className='text-lg font-medium'>Chi tiết sản phẩm xuất kho</h2>
						<Button color='primary' onPress={addRow}>
							Thêm sản phẩm
						</Button>
					</div>

					{rows.length > 0 && (
						<div className='overflow-x-auto'>
							<Table aria-label='Sản phẩm phiếu xuất kho'>
								<TableHeader>
									<TableColumn width={40}>STT</TableColumn>
									<TableColumn>Mã SP</TableColumn>
									<TableColumn>Tên sản phẩm</TableColumn>
									<TableColumn>Quy cách</TableColumn>
									<TableColumn>Dạng</TableColumn>
									<TableColumn>Đóng gói</TableColumn>
									<TableColumn width={90}>Số lượng</TableColumn>
									<TableColumn>Số lô</TableColumn>
									<TableColumn width={130}>NSX</TableColumn>
									<TableColumn width={130}>HSD</TableColumn>
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
													placeholder='Mã SP'
													value={row.productCode}
													onValueChange={v =>
														updateRow(row.key, { productCode: v })
													}
												/>
											</TableCell>
											<TableCell>
												<Input
													size='sm'
													placeholder='Tên SP'
													value={row.productName}
													onValueChange={v =>
														updateRow(row.key, { productName: v })
													}
												/>
											</TableCell>
											<TableCell>
												<Input
													size='sm'
													placeholder='Quy cách'
													value={row.specification}
													onValueChange={v =>
														updateRow(row.key, { specification: v })
													}
												/>
											</TableCell>
											<TableCell>
												<Input
													size='sm'
													placeholder='Dạng'
													value={row.type}
													onValueChange={v => updateRow(row.key, { type: v })}
												/>
											</TableCell>
											<TableCell>
												<Input
													size='sm'
													placeholder='Đóng gói'
													value={row.packaging}
													onValueChange={v =>
														updateRow(row.key, { packaging: v })
													}
												/>
											</TableCell>
											<TableCell>
												<Input
													size='sm'
													type='number'
													placeholder='SL'
													value={row.quantity}
													onValueChange={v =>
														updateRow(row.key, { quantity: v })
													}
												/>
											</TableCell>
											<TableCell>
												<Input
													size='sm'
													placeholder='Số lô'
													value={row.lotNumber}
													onValueChange={v =>
														updateRow(row.key, { lotNumber: v })
													}
												/>
											</TableCell>
											<TableCell>
												<Input
													size='sm'
													type='date'
													value={row.manufacturingDate}
													onValueChange={v =>
														updateRow(row.key, { manufacturingDate: v })
													}
												/>
											</TableCell>
											<TableCell>
												<Input
													size='sm'
													type='date'
													value={row.expiryDate}
													onValueChange={v =>
														updateRow(row.key, { expiryDate: v })
													}
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

					<div className='rounded-medium border border-warning bg-warning/10 p-3'>
						<p className='text-sm text-warning-700'>
							Nguyên tắc: Tồn kho Thành phẩm phải đủ hàng mới cho Xuất kho. Mỗi
							đơn hàng của Khách sẽ tạo 1 Phiếu xuất kho.
						</p>
					</div>

					<div className='flex justify-between items-start pt-4'>
						<div className='text-sm text-default-400 italic space-y-1'>
							<p>
								Nhân viên KẾ TOÁN KHO — Trưởng QL Kho (Duyệt) — Thủ kho (ký xuất
								kho)
							</p>
						</div>
						<div className='flex gap-2'>
							<Button
								variant='flat'
								onPress={() => navigate('/warehouse/export-slips')}
							>
								Hủy
							</Button>
							<Button
								color='primary'
								isDisabled={!canSave}
								onPress={handleSave}
							>
								Lưu phiếu
							</Button>
						</div>
					</div>
				</CardBody>
			</Card>
		</div>
	)
}

export default NewExportSlipPage
