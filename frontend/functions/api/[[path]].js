export async function onRequest(context) {
	const { request, env } = context
	const apiEndpoint =
		env.VITE_API_ENDPOINT_URL || 'https://medion.soltunemontepre.tech'
	const url = new URL(request.url)
	const path = url.pathname
	const targetUrl = `${apiEndpoint}${path}${url.search}`
	const newRequest = new Request(targetUrl, {
		method: request.method,
		headers: request.headers,
		body: request.body,
		redirect: 'manual',
	})
	return fetch(newRequest)
}
