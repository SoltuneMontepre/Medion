import React from 'react'
import { useLocation } from 'react-router'
import { Sidebar } from '../components/Sidebar'

const PUBLIC_PATHS = ['/']

const MainLayout = ({
	children,
}: {
	children: React.ReactNode
}): React.ReactElement => {
	const { pathname } = useLocation()
	const showSidebar = !PUBLIC_PATHS.includes(pathname)

	if (!showSidebar) {
		return <>{children}</>
	}

	return (
		<div className='flex h-screen w-full overflow-hidden bg-background'>
			<Sidebar />
			<main className='flex-1 overflow-auto min-w-0'>{children}</main>
		</div>
	)
}

export default MainLayout
