import React from 'react'
import registerGSAPPlugins from './config/registerGSAPPlugins'
import { RouterProvider } from 'react-router'
import router from './config/dynamicRouter'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { KeycloakProvider } from './contexts/KeycloakContext'

registerGSAPPlugins()

const queryClient = new QueryClient()

const App = (): React.ReactNode => {
	return (
		<KeycloakProvider>
			<QueryClientProvider client={queryClient}>
				<RouterProvider router={router} />
			</QueryClientProvider>
		</KeycloakProvider>
	)
}

export default App
