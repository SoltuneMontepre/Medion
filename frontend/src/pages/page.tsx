import React, { useState } from 'react'
import { useNavigate } from 'react-router'
import { Button, Card, CardBody, CardHeader, Input } from '@heroui/react'
import type { ApiResult } from '../services/apiResult'
import { useLogin, useGetMe } from '../services/Identity/identityApi'
import useAuth from '../hooks/useAuth'
import type { AuthToken, LoginRequest, User } from '../services/Identity/types'

const LoginPage = (): React.JSX.Element => {
	const navigate = useNavigate()
	const { setToken, setUser } = useAuth()
	const [form, setForm] = useState<LoginRequest>({
		userNameOrEmail: '',
		password: '',
	})

	const login = useLogin()
	const { refetch: getMe } = useGetMe({ enabled: false })

	const handleSubmit = async (e: React.FormEvent) => {
		e.preventDefault()
		const result = (await login.mutateAsync(form)) as ApiResult<AuthToken>
		if (!result.isSuccess || !result.data?.accessToken) return
		setToken(result.data.accessToken)
		const { data: meResult } = await getMe()
		if (meResult?.isSuccess && meResult.data) setUser(meResult.data as User)
		navigate('/dashboard')
	}

	return (
		<div className='min-h-screen center bg-content2'>
			<Card className='w-full max-w-sm' shadow='lg'>
				<CardHeader className='flex flex-col gap-1 px-8 pt-8 pb-0'>
					<h1 className='text-xl font-semibold'>Sign in</h1>
					<p className='text-small text-default-500'>
						Sign in with your username or email
					</p>
				</CardHeader>
				<CardBody className='gap-4 px-8 pb-8 pt-6'>
					<form onSubmit={handleSubmit} className='flex flex-col gap-4'>
						<Input
							label='Username or email'
							placeholder='Enter username or email'
							value={form.userNameOrEmail}
							onValueChange={v =>
								setForm(prev => ({ ...prev, userNameOrEmail: v }))
							}
							isRequired
							autoComplete='username'
							isInvalid={!!login.data?.errors?.userNameOrEmail}
							errorMessage={login.data?.errors?.userNameOrEmail?.[0]}
						/>
						<Input
							label='Password'
							placeholder='Enter password'
							type='password'
							value={form.password}
							onValueChange={v => setForm(prev => ({ ...prev, password: v }))}
							isRequired
							autoComplete='current-password'
							isInvalid={!!login.data?.errors?.password}
							errorMessage={login.data?.errors?.password?.[0]}
						/>
						{login.data && !login.data.isSuccess && login.data.message && (
							<p className='text-small text-danger'>{login.data.message}</p>
						)}
						<Button
							type='submit'
							color='primary'
							isLoading={login.isPending}
							className='w-full'
						>
							Sign in
						</Button>
					</form>
				</CardBody>
			</Card>
		</div>
	)
}

export default LoginPage
