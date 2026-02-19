import React from 'react'
import { Link } from 'react-router'
import { Button, Card, CardBody, CardHeader } from '@heroui/react'

const ORDERS_NEW_PATH = '/orders/new'

/** Danh sách đơn đặt hàng – Sale Admin (AC1: entry point) */
const OrderListPage = (): React.JSX.Element => {
	return (
		<div className='p-6'>
			<Card>
				<CardHeader className='flex flex-row items-center justify-between gap-4 flex-wrap'>
					<h1 className='text-xl font-semibold'>Danh sách đơn đặt hàng</h1>
					<Button
						as={Link}
						to={ORDERS_NEW_PATH}
						color='primary'
						className='shrink-0'
					>
						Tạo đơn đặt hàng
					</Button>
				</CardHeader>
				<CardBody>
					<p className='text-default-500'>
						Chọn &quot;Tạo đơn đặt hàng&quot; để tạo đơn mới. Danh sách đơn hàng
						sẽ được tổng hợp tại đây.
					</p>
				</CardBody>
			</Card>
		</div>
	)
}

export default OrderListPage
