import React, { useEffect } from 'react'
import { useNavigate, useLocation } from 'react-router'
import { Button, Spinner } from '@heroui/react'
import useAuth from '../hooks/useAuth'
import { useKeycloak } from '../contexts/KeycloakContext'

/** True when URL is the OAuth callback (do not trigger login() or we lose the code). */
function isKeycloakCallback(search: string): boolean {
	return search.includes('code=') || search.includes('state=')
}

/**
 * Entry page when not authenticated. Redirects to Keycloak login
 * or shows a sign-in button if Keycloak is not ready yet.
 */
const LoginPage = (): React.JSX.Element => {
	const navigate = useNavigate()
	const location = useLocation()
	const { isAuthenticated } = useAuth()
	const { isReady, login } = useKeycloak()
	const isCallback = isKeycloakCallback(location.search ?? '')

	useEffect(() => {
		if (!isReady) return
		if (isAuthenticated) {
			navigate('/dashboard', { replace: true })
			return
		}
		// Do not redirect to Keycloak if we're on the callback URL (let init process the code)
		if (isCallback) return
		// Redirect back to / so callback always lands on this public route (avoids ProtectedRoute seeing callback)
		login({ redirectUri: window.location.origin + '/' })
	}, [isReady, isAuthenticated, isCallback, login, navigate])

	if (!isReady || isCallback) {
		return (
			<div className='min-h-screen flex items-center justify-center bg-content2'>
				<Spinner size='lg' label={isCallback ? 'Signing in…' : 'Loading…'} />
			</div>
		)
	}

	return (
		<div className='min-h-screen flex flex-col items-center justify-center gap-4 bg-content2'>
			<Spinner size='lg' />
			<p className='text-default-500'>Redirecting to sign in…</p>
			<Button color='primary' onPress={() => login()}>
				Sign in with Keycloak
			</Button>
		</div>
	)
}

export default LoginPage
