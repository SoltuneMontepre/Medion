import { useMutation, useQuery } from '@tanstack/react-query'
import { apiCall } from '../apiResult'
import type { ApiResult } from '../apiResult'
import axiosInstance from '../axios'
import type {
	AuthToken,
	LoginRequest,
	RegisterUserRequest,
	User,
} from './types'

const AUTH_BASE = '/api/identity'

export const identityQueryKeys = {
	me: ['identity', 'me'] as const,
	user: (userId: string) => ['identity', 'user', userId] as const,
}

/** Login and get access token. Refresh token is set in HttpOnly cookie. */
export function useLogin() {
	return useMutation({
		mutationFn: (body: LoginRequest) =>
			apiCall(() =>
				axiosInstance.post<ApiResult<AuthToken>>(`${AUTH_BASE}/login`, body)
			),
	})
}

/** Register a new user. */
export function useRegister() {
	return useMutation({
		mutationFn: (body: RegisterUserRequest) =>
			apiCall(() =>
				axiosInstance.post<ApiResult<User>>(`${AUTH_BASE}/register`, body)
			),
	})
}

/** Get current user from JWT (requires Authorization header). */
export function useGetMe(options?: { enabled?: boolean }) {
	return useQuery({
		queryKey: identityQueryKeys.me,
		queryFn: () =>
			apiCall(() => axiosInstance.get<ApiResult<User>>(`${AUTH_BASE}/me`)),
		enabled: options?.enabled ?? true,
	})
}

/** Get user by id (requires Authorization header). */
export function useGetUserById(
	userId: string,
	options?: { enabled?: boolean }
) {
	return useQuery({
		queryKey: identityQueryKeys.user(userId),
		queryFn: () =>
			apiCall(() =>
				axiosInstance.get<ApiResult<User>>(`${AUTH_BASE}/user/${userId}`)
			),
		enabled: (options?.enabled ?? true) && !!userId,
	})
}

/** Refresh access token using refresh token from cookie. */
export function useRefreshToken() {
	return useMutation({
		mutationFn: () =>
			apiCall(() =>
				axiosInstance.post<ApiResult<AuthToken>>(`${AUTH_BASE}/refresh`)
			),
	})
}

/** Logout: blacklist token and clear refresh cookie (requires Authorization header). */
export function useLogout() {
	return useMutation({
		mutationFn: () =>
			apiCall(() =>
				axiosInstance.post<ApiResult<unknown>>(`${AUTH_BASE}/logout`)
			),
	})
}
