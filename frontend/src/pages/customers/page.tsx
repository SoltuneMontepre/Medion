import React from 'react'
import { Link } from 'react-router'
import {
	Button,
	Card,
	CardBody,
	CardHeader,
	Spinner,
	Table,
	TableBody,
	TableCell,
	TableColumn,
	TableHeader,
	TableRow,
} from '@heroui/react'
import { useGetAllCustomers } from '../../services/Sale/saleApi'
import type { Customer } from '../../services/Sale/types'

const CUSTOMER_NEW_PATH = '/customers/new'

/** Danh sách khách hàng – Sale Admin */
const CustomerListPage = (): React.JSX.Element => {
	const { data: customers, isLoading, error } = useGetAllCustomers()

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
							</TableHeader>
							<TableBody>
								{sortedCustomers.length === 0 ? (
									<TableRow>
										<TableCell
											colSpan={4}
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
										</TableRow>
									))
								)}
							</TableBody>
						</Table>
					)}
				</CardBody>
			</Card>
		</div>
	)
}

export default CustomerListPage
