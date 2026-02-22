import { create } from 'zustand'
import type { User } from '../services/Identity/types'

interface AuthState {
	token: string | null
	user: User | null
	isAuthenticated: boolean
	setToken: (token: string | null) => void
	setUser: (user: User | null) => void
	logout: () => void
}

const useAuth = create<AuthState>(set => ({
	token: null,
	user: null,
	isAuthenticated: false,
	setToken: token => set({ token, isAuthenticated: !!token }),
	setUser: user => set({ user }),
	logout: () => set({ token: null, user: null, isAuthenticated: false }),
}))

export default useAuth
