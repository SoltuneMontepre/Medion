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
	useDeleteProduct,
	useGetAllProducts,
} from '../../services/Sale/saleApi'
import type { Product } from '../../services/Sale/types'

const PRODUCT_NEW_PATH = '/products/new'

/** Danh sách sản phẩm */
const ProductListPage = (): React.JSX.Element => {
	const navigate = useNavigate()
	const { data: productsResult, isLoading, error } = useGetAllProducts()
	const deleteProduct = useDeleteProduct()
	const [deleteTarget, setDeleteTarget] = useState<Product | null>(null)

	const products = productsResult?.data ?? []

	const handleDeleteClick = (p: Product) => setDeleteTarget(p)
	const handleDeleteCancel = () => setDeleteTarget(null)
	const handleDeleteConfirm = async () => {
		if (!deleteTarget) return
		const result = await deleteProduct.mutateAsync(deleteTarget.id)
		if (result?.isSuccess) {
			addToast({ title: 'Đã xóa sản phẩm', color: 'success' })
			setDeleteTarget(null)
		} else {
			addToast({
				title: result?.message ?? 'Không thể xóa sản phẩm',
				color: 'danger',
			})
		}
	}

	return (
		<div className="p-6">
			<Card>
				<CardHeader className="flex flex-row items-center justify-between gap-4 flex-wrap">
					<h1 className="text-xl font-semibold">Danh sách sản phẩm</h1>
					<Button
						as={Link}
						to={PRODUCT_NEW_PATH}
						color="primary"
						className="shrink-0"
					>
						Thêm sản phẩm
					</Button>
				</CardHeader>
				<CardBody>
					{error && (
						<p className="text-danger text-sm mb-4">
							{(error as { message?: string })?.message ??
								'Không tải được danh sách.'}
						</p>
					)}
					{isLoading ? (
						<div className="flex justify-center py-8">
							<Spinner />
						</div>
					) : (
						<Table aria-label="Danh sách sản phẩm">
							<TableHeader>
								<TableColumn>Mã SP</TableColumn>
								<TableColumn>Tên sản phẩm</TableColumn>
								<TableColumn width={120} align="center">
									Thao tác
								</TableColumn>
							</TableHeader>
							<TableBody>
								{products.length === 0 ? (
									<TableRow>
										<TableCell
											colSpan={3}
											className="text-center text-default-500"
										>
											Chưa có sản phẩm. Nhấn &quot;Thêm sản phẩm&quot; để tạo.
										</TableCell>
									</TableRow>
								) : (
									products.map(p => (
										<TableRow key={p.id}>
											<TableCell className="font-medium">{p.code}</TableCell>
											<TableCell>{p.name}</TableCell>
											<TableCell align="center">
												<div className="flex gap-1 justify-center">
													<Button
														size="sm"
														variant="flat"
														color="primary"
														onPress={() =>
															navigate(`/products/${p.id}`)
														}
													>
														Sửa
													</Button>
													<Button
														size="sm"
														variant="flat"
														color="danger"
														onPress={() => handleDeleteClick(p)}
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

			<Modal isOpen={!!deleteTarget} onOpenChange={open => !open && setDeleteTarget(null)}>
				<ModalContent>
					<ModalHeader>Xác nhận xóa</ModalHeader>
					<ModalBody>
						{deleteTarget && (
							<p>
								Bạn có chắc muốn xóa sản phẩm &quot;{deleteTarget.code} -{' '}
								{deleteTarget.name}&quot;?
							</p>
						)}
					</ModalBody>
					<ModalFooter>
						<Button variant="flat" onPress={handleDeleteCancel}>
							Hủy
						</Button>
						<Button
							color="danger"
							onPress={handleDeleteConfirm}
							isLoading={deleteProduct.isPending}
						>
							Xóa
						</Button>
					</ModalFooter>
				</ModalContent>
			</Modal>
		</div>
	)
}

export default ProductListPage
