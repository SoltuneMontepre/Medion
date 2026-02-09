import React from 'react'
import useAuth from '../../hooks/useAuth'

const DashboardPage = (): React.JSX.Element => {
	const { user } = useAuth()

	if (!user) {
		return <div>Loading...</div>
	}

	return (
		<div className='p-6'>
			<h1 className='text-xl font-semibold'>Dashboard</h1>
			{user && (
				<p className='text-default-500 mt-2'>
					Welcome, {user.firstName ?? user.userName}.
				</p>
			)}
		</div>
	)
}

export default DashboardPage
