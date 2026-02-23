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
	Textarea,
} from '@heroui/react'

interface PlanRow {
	key: string
	productCode: string
	productName: string
	specification: string
	type: string
	packaging: string
	quantity: string
}

const EMPTY_ROW: Omit<PlanRow, 'key'> = {
	productCode: '',
	productName: '',
	specification: '',
	type: '',
	packaging: '',
	quantity: '',
}

/** Lập kế hoạch sản xuất mới – GMP Module */
const NewProductionPlanPage = (): React.JSX.Element => {
	const navigate = useNavigate()
	const [planDate, setPlanDate] = useState(
		() => new Date().toISOString().split('T')[0]
	)
	const [notes, setNotes] = useState('')
	const [rows, setRows] = useState<PlanRow[]>([])

	const addRow = useCallback(() => {
		setRows(prev => [
			...prev,
			{ ...EMPTY_ROW, key: `row-${Date.now()}-${prev.length}` },
		])
	}, [])

	const updateRow = useCallback((key: string, patch: Partial<PlanRow>) => {
		setRows(prev => prev.map(r => (r.key === key ? { ...r, ...patch } : r)))
	}, [])

	const removeRow = useCallback((key: string) => {
		setRows(prev => prev.filter(r => r.key !== key))
	}, [])

	const canSave =
		rows.length > 0 && rows.every(r => r.productCode && r.quantity)

	const handleSave = () => {
		// TODO: Call API to create production plan
		navigate('/production-plans', { replace: true })
	}

	return (
		<div className='p-6 max-w-5xl'>
			<Card>
				<CardHeader>
					<h1 className='text-xl font-semibold'>Lập kế hoạch sản xuất</h1>
				</CardHeader>
				<CardBody className='flex flex-col gap-6'>
					<p className='text-sm text-default-500'>
						Sau khi kiểm tra tồn kho TP thì nhân viên kế hoạch sẽ lên Bảng Kế
						hoạch SX cho từng ngày.
					</p>

					<div className='grid grid-cols-1 sm:grid-cols-2 gap-4'>
						<Input
							label='Ngày lập kế hoạch SX'
							type='date'
							value={planDate}
							onValueChange={setPlanDate}
						/>
					</div>

					<Textarea
						label='Ghi chú'
						placeholder='Ghi chú cho kế hoạch sản xuất...'
						value={notes}
						onValueChange={setNotes}
						minRows={2}
					/>

					<div className='flex items-center justify-between gap-4 flex-wrap'>
						<h2 className='text-lg font-medium'>
							Danh sách sản phẩm cần sản xuất
						</h2>
						<Button color='primary' onPress={addRow}>
							Thêm sản phẩm
						</Button>
					</div>

					{rows.length > 0 && (
						<Table aria-label='Sản phẩm kế hoạch SX'>
							<TableHeader>
								<TableColumn width={40}>STT</TableColumn>
								<TableColumn>Mã SP</TableColumn>
								<TableColumn>Tên sản phẩm</TableColumn>
								<TableColumn>Quy cách</TableColumn>
								<TableColumn>Dạng</TableColumn>
								<TableColumn>Đóng gói</TableColumn>
								<TableColumn width={120}>Số lượng</TableColumn>
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
												onValueChange={v => updateRow(row.key, { quantity: v })}
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
					)}

					<div className='flex justify-between pt-4'>
						<p className='text-sm text-default-400 italic'>
							Nhân viên phòng Kế hoạch lập — Trưởng phòng Kế hoạch duyệt
						</p>
						<div className='flex gap-2'>
							<Button
								variant='flat'
								onPress={() => navigate('/production-plans')}
							>
								Hủy
							</Button>
							<Button
								color='primary'
								isDisabled={!canSave}
								onPress={handleSave}
							>
								Lưu kế hoạch
							</Button>
						</div>
					</div>
				</CardBody>
			</Card>
		</div>
	)
}

export default NewProductionPlanPage
