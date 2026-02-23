import React, { useEffect } from 'react'
import { useNavigate } from 'react-router'
import { Spinner } from '@heroui/react'
import useAuth from '../hooks/useAuth'
import { useKeycloak } from '../contexts/KeycloakContext'

const LoginPage = (): React.JSX.Element => {
	const navigate = useNavigate()
	const { isAuthenticated } = useAuth()
	const { login } = useKeycloak()

	useEffect(() => {
		if (isAuthenticated) {
			navigate('/dashboard', { replace: true })
			return
		}
		login({ redirectUri: window.location.origin + '/' })
	}, [isAuthenticated, login, navigate])

	return (
		<div className='min-h-screen flex items-center justify-center bg-content2'>
			<Spinner size='lg' label='Redirecting to sign in…' />
		</div>
	)
}

export default LoginPage
