import axios from 'axios'
import useAuth from '../hooks/useAuth'

const ApiUrl = import.meta.env.VITE_API_ENDPOINT_URL

const axiosInstance = axios.create({
	baseURL: ApiUrl,
	timeout: 10000,
	headers: {
		'Content-Type': 'application/json',
	},
	withCredentials: true,
})

axiosInstance.interceptors.request.use(config => {
	const token = useAuth.getState().token
	if (token) {
		config.headers.Authorization = `Bearer ${token}`
	}
	return config
})

export default axiosInstance
