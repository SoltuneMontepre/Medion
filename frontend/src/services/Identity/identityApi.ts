import { useMutation, useQuery } from '@tanstack/react-query'
import { apiCall } from '../apiResult'
import type { ApiResult } from '../apiResult'
import axiosInstance from '../axios'
import type { RegisterUserRequest, User } from './types'

const AUTH_BASE = '/api/identity'

export const identityQueryKeys = {
	me: ['identity', 'me'] as const,
	user: (userId: string) => ['identity', 'user', userId] as const,
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
