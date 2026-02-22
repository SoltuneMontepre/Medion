import axios from 'axios'
import useAuth from '../hooks/useAuth'
import { getKeycloakInstance } from '../contexts/KeycloakContext'

const ApiUrl = import.meta.env.VITE_API_ENDPOINT_URL

const axiosInstance = axios.create({
	baseURL: ApiUrl,
	timeout: 10000,
	headers: {
		'Content-Type': 'application/json',
	},
	withCredentials: true,
})

axiosInstance.interceptors.request.use(async config => {
	const kc = getKeycloakInstance()
	if (kc?.authenticated) {
		try {
			const refreshed = await kc.updateToken(30)
			if (refreshed && kc.token) {
				useAuth.getState().setToken(kc.token)
			}
			if (kc.token) {
				config.headers.Authorization = `Bearer ${kc.token}`
			}
		} catch {
			useAuth.getState().logout()
		}
	} else {
		const token = useAuth.getState().token
		if (token) {
			config.headers.Authorization = `Bearer ${token}`
		}
	}
	return config
})

export default axiosInstance
