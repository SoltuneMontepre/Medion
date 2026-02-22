import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import './global.css'
import { HeroUIProvider, ToastProvider } from '@heroui/react'

createRoot(document.getElementById('root')!).render(
	<StrictMode>
		<HeroUIProvider>
			<ToastProvider placement='top-right' />
			<App />
		</HeroUIProvider>
	</StrictMode>
)
