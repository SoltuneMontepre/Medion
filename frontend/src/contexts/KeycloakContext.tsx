import React, {
	createContext,
	useCallback,
	useContext,
	useEffect,
	useRef,
	useState,
} from 'react'
import Keycloak from 'keycloak-js'
import { keycloakConfig } from '../config/keycloak'
import useAuth from '../hooks/useAuth'
import type { User } from '../services/Identity/types'

/** JWT payload shape from Keycloak (standard OIDC claims). */
interface KeycloakTokenParsed {
	sub?: string
	preferred_username?: string
	name?: string
	email?: string
	given_name?: string
	family_name?: string
	realm_access?: { roles?: string[] }
	resource_access?: Record<string, { roles?: string[] }>
	exp?: number
}

function parseUserFromToken(token: string | undefined): User | null {
	if (!token) return null
	try {
		const payload = JSON.parse(
			atob(token.split('.')[1] ?? 'e30=')
		) as KeycloakTokenParsed
		const roles: string[] = [
			...(payload.realm_access?.roles ?? []),
			...Object.values(payload.resource_access ?? {}).flatMap(
				r => r.roles ?? []
			),
		]
		return {
			id: payload.sub ?? '',
			userName: payload.preferred_username ?? payload.sub ?? '',
			email: payload.email ?? '',
			firstName: payload.given_name ?? payload.name?.split(' ')[0] ?? '',
			lastName:
				payload.family_name ??
				payload.name?.split(' ').slice(1).join(' ') ??
				'',
			emailConfirmed: true,
			phoneNumberConfirmed: false,
			isActive: true,
			createdAt: new Date().toISOString(),
			roles: [...new Set(roles)],
		}
	} catch {
		return null
	}
}

export type KeycloakContextValue = {
	isReady: boolean
	login: (options?: { redirectUri?: string }) => void
	logout: (options?: { redirectUri?: string }) => void
}

const KeycloakContext = createContext<KeycloakContextValue | null>(null)

let keycloakInstance: Keycloak | null = null

/* eslint-disable react-refresh/only-export-components -- context module exports provider + hook + instance getter */
export function setKeycloakInstance(kc: Keycloak | null): void {
	keycloakInstance = kc
}

export function getKeycloakInstance(): Keycloak | null {
	return keycloakInstance
}

export function useKeycloak(): KeycloakContextValue {
	const value = useContext(KeycloakContext)
	if (value == null) {
		throw new Error('useKeycloak must be used within KeycloakProvider')
	}
	return value
}

type KeycloakProviderProps = { children: React.ReactNode }

export function KeycloakProvider({
	children,
}: KeycloakProviderProps): React.ReactElement {
	const [isReady, setIsReady] = useState(false)
	const initStarted = useRef(false)
	const { setToken, setUser, logout: clearAuth } = useAuth()

	const syncAuth = useCallback(
		(kc: Keycloak) => {
			if (kc.authenticated && kc.token) {
				setToken(kc.token)
				const user = parseUserFromToken(kc.token)
				if (user) setUser(user)
			} else {
				clearAuth()
			}
		},
		[setToken, setUser, clearAuth]
	)

	useEffect(() => {
		if (initStarted.current) return
		initStarted.current = true

		const kc = new Keycloak(keycloakConfig)
		setKeycloakInstance(kc)

		kc.onTokenExpired = () => {
			kc.updateToken(30)
				.then(refreshed => {
					if (refreshed && kc.token) {
						setToken(kc.token)
						const user = parseUserFromToken(kc.token)
						if (user) setUser(user)
					}
				})
				.catch(() => {
					clearAuth()
				})
		}

		kc.init({ onLoad: 'check-sso' })
			.then(() => {
				syncAuth(kc)
				setIsReady(true)
			})
			.catch(err => {
				console.error('Keycloak init failed', err)
				setKeycloakInstance(null)
				clearAuth()
				setIsReady(true)
			})
	}, [syncAuth, setToken, setUser, clearAuth])

	const login = useCallback((options?: { redirectUri?: string }) => {
		const kc = getKeycloakInstance()
		if (kc) {
			kc.login({ redirectUri: options?.redirectUri ?? window.location.href })
		}
	}, [])

	const logout = useCallback(
		(options?: { redirectUri?: string }) => {
			clearAuth()
			const kc = getKeycloakInstance()
			setKeycloakInstance(null)
			const redirectUri = options?.redirectUri ?? window.location.origin + '/'
			if (kc) {
				kc.logout({ redirectUri })
			}
		},
		[clearAuth]
	)

	const value: KeycloakContextValue = {
		isReady,
		login,
		logout,
	}

	return (
		<KeycloakContext.Provider value={value}>
			{children}
		</KeycloakContext.Provider>
	)
}
