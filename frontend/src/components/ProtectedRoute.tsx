import React from 'react'
import { Navigate, useLocation } from 'react-router'
import useAuth from '../hooks/useAuth'

type ProtectedRouteProps = {
	children: React.ReactNode
}

/**
 * Wraps content that requires authentication. Redirects to login if not authenticated.
 */
const ProtectedRoute = ({
	children,
}: ProtectedRouteProps): React.ReactElement => {
	const { isAuthenticated } = useAuth()
	const location = useLocation()

	if (!isAuthenticated) {
		return <Navigate to='/' state={{ from: location }} replace />
	}

	return <>{children}</>
}

export default ProtectedRoute
