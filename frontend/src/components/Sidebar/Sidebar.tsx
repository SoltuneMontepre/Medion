import React, { useState } from 'react'
import { NavLink } from 'react-router'
import { Button, Divider, Tooltip } from '@heroui/react'
import { useKeycloak } from '../../contexts/KeycloakContext'

const IconDashboard = () => (
	<svg
		width='20'
		height='20'
		viewBox='0 0 24 24'
		fill='none'
		stroke='currentColor'
		strokeWidth='2'
		strokeLinecap='round'
		strokeLinejoin='round'
	>
		<rect x='3' y='3' width='7' height='9' rx='1' />
		<rect x='14' y='3' width='7' height='5' rx='1' />
		<rect x='14' y='12' width='7' height='9' rx='1' />
		<rect x='3' y='16' width='7' height='5' rx='1' />
	</svg>
)
const IconChevronLeft = () => (
	<svg
		width='20'
		height='20'
		viewBox='0 0 24 24'
		fill='none'
		stroke='currentColor'
		strokeWidth='2'
		strokeLinecap='round'
		strokeLinejoin='round'
	>
		<polyline points='15 18 9 12 15 6' />
	</svg>
)
const IconChevronRight = () => (
	<svg
		width='20'
		height='20'
		viewBox='0 0 24 24'
		fill='none'
		stroke='currentColor'
		strokeWidth='2'
		strokeLinecap='round'
		strokeLinejoin='round'
	>
		<polyline points='9 18 15 12 9 6' />
	</svg>
)
const IconUsers = () => (
	<svg
		width='20'
		height='20'
		viewBox='0 0 24 24'
		fill='none'
		stroke='currentColor'
		strokeWidth='2'
		strokeLinecap='round'
		strokeLinejoin='round'
	>
		<path d='M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2' />
		<circle cx='9' cy='7' r='4' />
		<path d='M23 21v-2a4 4 0 0 0-3-3.87' />
		<path d='M16 3.13a4 4 0 0 1 0 7.75' />
	</svg>
)
const IconOrder = () => (
	<svg
		width='20'
		height='20'
		viewBox='0 0 24 24'
		fill='none'
		stroke='currentColor'
		strokeWidth='2'
		strokeLinecap='round'
		strokeLinejoin='round'
	>
		<path d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z' />
		<polyline points='14 2 14 8 20 8' />
		<line x1='16' y1='13' x2='8' y2='13' />
		<line x1='16' y1='17' x2='8' y2='17' />
		<polyline points='10 9 9 9 8 9' />
	</svg>
)
const IconListSummary = () => (
	<svg
		width='20'
		height='20'
		viewBox='0 0 24 24'
		fill='none'
		stroke='currentColor'
		strokeWidth='2'
		strokeLinecap='round'
		strokeLinejoin='round'
	>
		<line x1='8' y1='6' x2='21' y2='6' />
		<line x1='8' y1='12' x2='21' y2='12' />
		<line x1='8' y1='18' x2='21' y2='18' />
		<line x1='3' y1='6' x2='3.01' y2='6' />
		<line x1='3' y1='12' x2='3.01' y2='12' />
		<line x1='3' y1='18' x2='3.01' y2='18' />
	</svg>
)
const IconLock = () => (
	<svg
		width='20'
		height='20'
		viewBox='0 0 24 24'
		fill='none'
		stroke='currentColor'
		strokeWidth='2'
		strokeLinecap='round'
		strokeLinejoin='round'
	>
		<rect x='3' y='11' width='18' height='11' rx='2' ry='2' />
		<path d='M7 11V7a5 5 0 0 1 10 0v4' />
	</svg>
)
const IconInventory = () => (
	<svg
		width='20'
		height='20'
		viewBox='0 0 24 24'
		fill='none'
		stroke='currentColor'
		strokeWidth='2'
		strokeLinecap='round'
		strokeLinejoin='round'
	>
		<path d='M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z' />
		<polyline points='3.27 6.96 12 12.01 20.73 6.96' />
		<line x1='12' y1='22.08' x2='12' y2='12' />
	</svg>
)
const IconCalendar = () => (
	<svg
		width='20'
		height='20'
		viewBox='0 0 24 24'
		fill='none'
		stroke='currentColor'
		strokeWidth='2'
		strokeLinecap='round'
		strokeLinejoin='round'
	>
		<rect x='3' y='4' width='18' height='18' rx='2' ry='2' />
		<line x1='16' y1='2' x2='16' y2='6' />
		<line x1='8' y1='2' x2='8' y2='6' />
		<line x1='3' y1='10' x2='21' y2='10' />
	</svg>
)
const IconFactory = () => (
	<svg
		width='20'
		height='20'
		viewBox='0 0 24 24'
		fill='none'
		stroke='currentColor'
		strokeWidth='2'
		strokeLinecap='round'
		strokeLinejoin='round'
	>
		<path d='M2 20h20' />
		<path d='M9 20V6l7-3v17' />
		<path d='M2 20v-5l5-2' />
		<path d='M16 20v-9l6-4v13' />
	</svg>
)
const IconClipboardCheck = () => (
	<svg
		width='20'
		height='20'
		viewBox='0 0 24 24'
		fill='none'
		stroke='currentColor'
		strokeWidth='2'
		strokeLinecap='round'
		strokeLinejoin='round'
	>
		<path d='M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2' />
		<rect x='8' y='2' width='8' height='4' rx='1' ry='1' />
		<path d='M9 14l2 2 4-4' />
	</svg>
)
const IconWarehouse = () => (
	<svg
		width='20'
		height='20'
		viewBox='0 0 24 24'
		fill='none'
		stroke='currentColor'
		strokeWidth='2'
		strokeLinecap='round'
		strokeLinejoin='round'
	>
		<path d='M22 8.35V20a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V8.35A2 2 0 0 1 3.26 6.5l8-3.2a2 2 0 0 1 1.48 0l8 3.2A2 2 0 0 1 22 8.35z' />
		<line x1='6' y1='18' x2='6' y2='14' />
		<line x1='10' y1='18' x2='10' y2='14' />
		<line x1='14' y1='18' x2='14' y2='14' />
		<line x1='18' y1='18' x2='18' y2='14' />
	</svg>
)
const IconTruck = () => (
	<svg
		width='20'
		height='20'
		viewBox='0 0 24 24'
		fill='none'
		stroke='currentColor'
		strokeWidth='2'
		strokeLinecap='round'
		strokeLinejoin='round'
	>
		<rect x='1' y='3' width='15' height='13' />
		<polygon points='16 8 20 8 23 11 23 16 16 16 16 8' />
		<circle cx='5.5' cy='18.5' r='2.5' />
		<circle cx='18.5' cy='18.5' r='2.5' />
	</svg>
)
const IconLogout = () => (
	<svg
		width='20'
		height='20'
		viewBox='0 0 24 24'
		fill='none'
		stroke='currentColor'
		strokeWidth='2'
		strokeLinecap='round'
		strokeLinejoin='round'
	>
		<path d='M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4' />
		<polyline points='16 17 21 12 16 7' />
		<line x1='21' y1='12' x2='9' y2='12' />
	</svg>
)

export type SidebarNavItem = {
	key: string
	label: string
	href: string
	icon: React.ReactNode
}

export type SidebarNavGroup = {
	key: string
	label: string
	items: SidebarNavItem[]
}

const defaultNavGroups: SidebarNavGroup[] = [
	{
		key: 'general',
		label: 'Tổng quan',
		items: [
			{
				key: 'dashboard',
				label: 'Dashboard',
				href: '/dashboard',
				icon: <IconDashboard />,
			},
		],
	},
	{
		key: 'sales',
		label: 'Kinh doanh',
		items: [
			{
				key: 'customers',
				label: 'Khách hàng',
				href: '/customers',
				icon: <IconUsers />,
			},
			{
				key: 'orders',
				label: 'Đơn đặt hàng',
				href: '/orders',
				icon: <IconOrder />,
			},
			{
				key: 'order-summary',
				label: 'Tổng hợp đơn hàng',
				href: '/orders/summary',
				icon: <IconListSummary />,
			},
		],
	},
	{
		key: 'production',
		label: 'Sản xuất',
		items: [
			{
				key: 'production-plans',
				label: 'Kế hoạch SX',
				href: '/production-plans',
				icon: <IconCalendar />,
			},
			{
				key: 'production-orders',
				label: 'Lệnh sản xuất',
				href: '/production-orders',
				icon: <IconFactory />,
			},
			{
				key: 'quality-control',
				label: 'Kiểm tra CL (KCS)',
				href: '/quality-control',
				icon: <IconClipboardCheck />,
			},
		],
	},
	{
		key: 'warehouse',
		label: 'Kho',
		items: [
			{
				key: 'inventory',
				label: 'Tồn kho',
				href: '/inventory',
				icon: <IconInventory />,
			},
			{
				key: 'warehouse-receipts',
				label: 'Nhập kho TP',
				href: '/warehouse/receipts',
				icon: <IconWarehouse />,
			},
			{
				key: 'export-slips',
				label: 'Phiếu xuất kho TP',
				href: '/warehouse/export-slips',
				icon: <IconOrder />,
			},
		],
	},
	{
		key: 'logistics',
		label: 'Vận chuyển',
		items: [
			{
				key: 'delivery',
				label: 'Giao hàng',
				href: '/delivery',
				icon: <IconTruck />,
			},
		],
	},
	{
		key: 'settings',
		label: 'Cài đặt',
		items: [
			{
				key: 'transaction-pin',
				label: 'Mã PIN giao dịch',
				href: '/settings/transaction-pin',
				icon: <IconLock />,
			},
		],
	},
]

const SIDEBAR_WIDTH_EXPANDED = 256
const SIDEBAR_WIDTH_COLLAPSED = 64

type SidebarProps = {
	navGroups?: SidebarNavGroup[]
	title?: string
}

const Sidebar = ({
	navGroups = defaultNavGroups,
	title = 'Medion',
}: SidebarProps): React.ReactElement => {
	const [collapsed, setCollapsed] = useState(false)
	const { logout } = useKeycloak()

	const handleLogout = () => {
		logout()
	}

	const renderNavItem = (item: SidebarNavItem) => {
		const linkContent = (
			<NavLink
				to={item.href}
				className={({ isActive: active }) =>
					`flex items-center gap-3 w-full min-h-9 px-3 rounded-medium text-sm transition-colors outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-1 ${
						active
							? 'bg-primary text-primary-foreground font-medium'
							: 'text-foreground hover:bg-content2'
					}`
				}
				end={item.href === '/'}
			>
				<span
					className='shrink-0 flex items-center justify-center w-8 h-8 rounded-medium [&_svg]:shrink-0'
					aria-hidden
				>
					{item.icon}
				</span>
				{!collapsed && <span className='truncate'>{item.label}</span>}
			</NavLink>
		)
		return (
			<li key={item.key}>
				{collapsed ? (
					<Tooltip
						content={item.label}
						placement='right'
						delay={0}
						closeDelay={0}
					>
						{linkContent}
					</Tooltip>
				) : (
					linkContent
				)}
			</li>
		)
	}

	return (
		<aside
			className='flex flex-col h-full bg-content1 border-r border-divider transition-[width] duration-200 ease-out shrink-0'
			style={{
				width: collapsed ? SIDEBAR_WIDTH_COLLAPSED : SIDEBAR_WIDTH_EXPANDED,
			}}
		>
			{/* Header / Logo strip */}
			<div className='flex items-center h-12 min-h-12 px-3 border-b border-divider shrink-0'>
				{!collapsed && (
					<span className='text-sm font-semibold text-foreground truncate'>
						{title}
					</span>
				)}
				{collapsed && (
					<span className='text-sm font-semibold text-foreground truncate'>
						{title.slice(0, 1)}
					</span>
				)}
			</div>

			{/* Nav */}
			<nav className='flex-1 overflow-y-auto py-2'>
				{navGroups.map((group, gIdx) => (
					<div key={group.key} className={gIdx > 0 ? 'mt-3' : ''}>
						{!collapsed && (
							<p className='px-5 pb-1 text-tiny font-semibold text-default-400 uppercase tracking-wider'>
								{group.label}
							</p>
						)}
						{collapsed && gIdx > 0 && <Divider className='my-1 mx-2' />}
						<ul className='flex flex-col gap-0.5 px-2'>
							{group.items.map(renderNavItem)}
						</ul>
					</div>
				))}
			</nav>

			<Divider />

			{/* Logout */}
			<div className='px-2 py-1'>
				{collapsed ? (
					<Tooltip content='Log out' placement='right' delay={0} closeDelay={0}>
						<Button
							isIconOnly
							variant='light'
							size='sm'
							className='w-full min-w-0 text-foreground'
							onPress={handleLogout}
							aria-label='Log out'
						>
							<IconLogout />
						</Button>
					</Tooltip>
				) : (
					<Button
						variant='light'
						size='sm'
						className='w-full justify-start gap-3 text-foreground'
						onPress={handleLogout}
						startContent={<IconLogout />}
					>
						Log out
					</Button>
				)}
			</div>

			<Divider />

			{/* Collapse toggle */}
			<div className='p-2 border-t border-divider'>
				<Tooltip
					content={collapsed ? 'Expand' : 'Collapse'}
					placement='right'
					delay={0}
					closeDelay={0}
				>
					<Button
						isIconOnly
						variant='light'
						size='sm'
						className='w-full min-w-0'
						onPress={() => setCollapsed(c => !c)}
						aria-label={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
					>
						{collapsed ? <IconChevronRight /> : <IconChevronLeft />}
					</Button>
				</Tooltip>
			</div>
		</aside>
	)
}

export default Sidebar
