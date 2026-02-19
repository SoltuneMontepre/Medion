import React from 'react'
import { Navigate, useLocation } from 'react-router'
import useAuth from '../hooks/useAuth'

type PublicRouteProps = {
	children: React.ReactNode
}

/**
 * Wraps public-only content (e.g. login). Redirects to dashboard if already authenticated.
 */
const PublicRoute = ({ children }: PublicRouteProps): React.ReactElement => {
	const { isAuthenticated } = useAuth()
	const location = useLocation()
	const from = (location.state as { from?: { pathname: string } })?.from
		?.pathname

	if (isAuthenticated) {
		return <Navigate to={from ?? '/dashboard'} replace />
	}

	return <>{children}</>
}

export default PublicRoute
