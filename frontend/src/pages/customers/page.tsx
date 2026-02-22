import React, { useState } from 'react'
import { Link, useNavigate } from 'react-router'
import {
	Button,
	Card,
	CardBody,
	CardHeader,
	Modal,
	ModalBody,
	ModalContent,
	ModalFooter,
	ModalHeader,
	Spinner,
	Table,
	TableBody,
	TableCell,
	TableColumn,
	TableHeader,
	TableRow,
} from '@heroui/react'
import { addToast } from '@heroui/react'
import {
	useDeleteCustomer,
	useGetAllCustomers,
} from '../../services/Sale/saleApi'
import type { Customer } from '../../services/Sale/types'

const CUSTOMER_NEW_PATH = '/customers/new'

/** Danh sách khách hàng – Sale Admin */
const CustomerListPage = (): React.JSX.Element => {
	const navigate = useNavigate()
	const { data: customers, isLoading, error } = useGetAllCustomers()
	const deleteCustomer = useDeleteCustomer()
	const [deleteTarget, setDeleteTarget] = useState<Customer | null>(null)

	const handleDeleteClick = (c: Customer) => setDeleteTarget(c)
	const handleDeleteCancel = () => setDeleteTarget(null)
	const handleDeleteConfirm = async () => {
		if (!deleteTarget) return
		const result = await deleteCustomer.mutateAsync(deleteTarget.id)
		if (result?.isSuccess) {
			addToast({ title: 'Đã xóa khách hàng', color: 'success' })
			setDeleteTarget(null)
		} else {
			addToast({
				title: result?.message ?? 'Không thể xóa khách hàng',
				color: 'danger',
			})
		}
	}

	// Hiển thị mới nhất trước (AC2: khách vừa tạo ở hàng đầu tiên)
	const sortedCustomers = React.useMemo(() => {
		const raw = customers?.data
		if (!raw || !Array.isArray(raw)) return []
		const list = [...raw]
		list.sort(
			(a, b) =>
				new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
		)
		return list
	}, [customers?.data])

	const fullName = (c: Customer) =>
		[c.lastName, c.firstName].filter(Boolean).join(' ').trim() || '—'

	return (
		<div className='p-6'>
			<Card>
				<CardHeader className='flex flex-row items-center justify-between gap-4 flex-wrap'>
					<h1 className='text-xl font-semibold'>Danh sách khách hàng</h1>
					<Button
						as={Link}
						to={CUSTOMER_NEW_PATH}
						color='primary'
						className='shrink-0'
					>
						Tạo khách hàng mới
					</Button>
				</CardHeader>
				<CardBody>
					{error && (
						<p className='text-danger text-sm mb-4'>
							{(error as { message?: string })?.message ??
								'Không tải được danh sách.'}
						</p>
					)}
					{isLoading ? (
						<div className='flex justify-center py-8'>
							<Spinner />
						</div>
					) : (
						<Table aria-label='Danh sách khách hàng'>
							<TableHeader>
								<TableColumn>Mã KH</TableColumn>
								<TableColumn>Tên khách hàng</TableColumn>
								<TableColumn>Địa chỉ</TableColumn>
								<TableColumn>Số điện thoại</TableColumn>
								<TableColumn width={120} align='center'>
									Thao tác
								</TableColumn>
							</TableHeader>
							<TableBody>
								{sortedCustomers.length === 0 ? (
									<TableRow>
										<TableCell
											colSpan={5}
											className='text-center text-default-500'
										>
											Chưa có khách hàng. Nhấn &quot;Tạo khách hàng mới&quot; để
											thêm.
										</TableCell>
									</TableRow>
								) : (
									sortedCustomers.map(c => (
										<TableRow key={c.id}>
											<TableCell>{c.code}</TableCell>
											<TableCell>{fullName(c)}</TableCell>
											<TableCell>{c.address || '—'}</TableCell>
											<TableCell>{c.phoneNumber || '—'}</TableCell>
											<TableCell align='center'>
												<div className='flex gap-1 justify-center'>
													<Button
														size='sm'
														variant='flat'
														color='primary'
														onPress={() =>
															navigate(`/customers/${c.id}`)
														}
													>
														Sửa
													</Button>
													<Button
														size='sm'
														variant='flat'
														color='danger'
														onPress={() => handleDeleteClick(c)}
													>
														Xóa
													</Button>
												</div>
											</TableCell>
										</TableRow>
									))
								)}
							</TableBody>
						</Table>
					)}
				</CardBody>
			</Card>

			<Modal
				isOpen={!!deleteTarget}
				onOpenChange={open => !open && setDeleteTarget(null)}
			>
				<ModalContent>
					<ModalHeader>Xác nhận xóa</ModalHeader>
					<ModalBody>
						{deleteTarget && (
							<p>
								Bạn có chắc muốn xóa khách hàng &quot;{deleteTarget.code} -{' '}
								{fullName(deleteTarget)}&quot;?
							</p>
						)}
					</ModalBody>
					<ModalFooter>
						<Button variant='flat' onPress={handleDeleteCancel}>
							Hủy
						</Button>
						<Button
							color='danger'
							onPress={handleDeleteConfirm}
							isLoading={deleteCustomer.isPending}
						>
							Xóa
						</Button>
					</ModalFooter>
				</ModalContent>
			</Modal>
		</div>
	)
}

export default CustomerListPage
