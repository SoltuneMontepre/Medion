import React, { useState } from 'react'
import { NavLink } from 'react-router'
import { Button, Divider, Tooltip } from '@heroui/react'
import { useKeycloak } from '../../contexts/KeycloakContext'

// Simple SAP-style icons (outline, 20px)
const IconHome = () => (
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
		<path d='M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z' />
		<polyline points='9 22 9 12 15 12 15 22' />
	</svg>
)
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

const defaultNavItems: SidebarNavItem[] = [
	{ key: 'home', label: 'Home', href: '/', icon: <IconHome /> },
	{
		key: 'dashboard',
		label: 'Dashboard',
		href: '/dashboard',
		icon: <IconDashboard />,
	},
	{
		key: 'customers',
		label: 'Danh sách khách hàng',
		href: '/customers',
		icon: <IconUsers />,
	},
	{
		key: 'orders',
		label: 'Danh sách đơn đặt hàng',
		href: '/orders',
		icon: <IconOrder />,
	},
	{
		key: 'transaction-pin',
		label: 'Mã PIN giao dịch',
		href: '/settings/transaction-pin',
		icon: <IconLock />,
	},
]

const SIDEBAR_WIDTH_EXPANDED = 256
const SIDEBAR_WIDTH_COLLAPSED = 64

type SidebarProps = {
	navItems?: SidebarNavItem[]
	title?: string
}

const Sidebar = ({
	navItems = defaultNavItems,
	title = 'Medion',
}: SidebarProps): React.ReactElement => {
	const [collapsed, setCollapsed] = useState(false)
	const { logout } = useKeycloak()

	const handleLogout = () => {
		logout()
	}

	return (
		<aside
			className='flex flex-col h-full bg-content1 border-r border-divider transition-[width] duration-200 ease-out shrink-0'
			style={{
				width: collapsed ? SIDEBAR_WIDTH_COLLAPSED : SIDEBAR_WIDTH_EXPANDED,
			}}
		>
			{/* Header / Logo strip - SAP shell style */}
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
				<ul className='flex flex-col gap-0.5 px-2'>
					{navItems.map(item => {
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
					})}
				</ul>
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
