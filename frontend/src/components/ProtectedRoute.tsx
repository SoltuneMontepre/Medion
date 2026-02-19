import React from 'react'
import { Navigate, useLocation } from 'react-router'
import { Spinner } from '@heroui/react'
import useAuth from '../hooks/useAuth'
import { useKeycloak } from '../contexts/KeycloakContext'

type ProtectedRouteProps = {
	children: React.ReactNode
}

/** True when URL is the OAuth callback (Keycloak will process code/state). */
function isKeycloakCallback(search: string): boolean {
	return search.includes('code=') || search.includes('state=')
}

/**
 * Wraps content that requires authentication. Redirects to login if not authenticated.
 * Does not redirect while we're on the Keycloak callback URL (so init can process the code).
 */
const ProtectedRoute = ({
	children,
}: ProtectedRouteProps): React.ReactElement => {
	const { isAuthenticated } = useAuth()
	const { isReady } = useKeycloak()
	const location = useLocation()
	const isCallback = isKeycloakCallback(location.search ?? '')

	if (isCallback && !isReady) {
		return (
			<div className='min-h-screen flex items-center justify-center bg-content2'>
				<Spinner size='lg' label='Signing in…' />
			</div>
		)
	}

	if (!isAuthenticated) {
		return <Navigate to='/' state={{ from: location }} replace />
	}

	return <>{children}</>
}

export default ProtectedRoute
