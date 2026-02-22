import React from 'react'
import { Navigate, useLocation } from 'react-router'
import { Spinner } from '@heroui/react'
import useAuth from '../hooks/useAuth'
import { useKeycloak } from '../contexts/KeycloakContext'

type ProtectedRouteProps = {
	children: React.ReactNode
}

const ProtectedRoute = ({
	children,
}: ProtectedRouteProps): React.ReactElement => {
	const { isAuthenticated } = useAuth()
	const { isReady } = useKeycloak()
	const location = useLocation()

	if (!isReady) {
		return (
			<div className='min-h-screen flex items-center justify-center bg-content2'>
				<Spinner size='lg' />
			</div>
		)
	}

	if (!isAuthenticated) {
		return <Navigate to='/' state={{ from: location }} replace />
	}

	return <>{children}</>
}

export default ProtectedRoute
