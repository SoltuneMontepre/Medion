export async function onRequest(context) {
  const { request, env } = context;

  // Get the API endpoint from environment variable or use default
  const apiEndpoint = env.API_ENDPOINT_URL || 'https://medion.soltunemontepre.tech';

  // Get the path from the request
  const url = new URL(request.url);
  const path = url.pathname.replace('/api', '');

  // Build the target URL
  const targetUrl = `${apiEndpoint}${path}${url.search}`;

  // Create a new request with the same headers and body
  const newRequest = new Request(targetUrl, {
    method: request.method,
    headers: request.headers,
    body: request.body,
    redirect: 'follow',
  });

  return fetch(newRequest);
}
