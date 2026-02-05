export async function onRequest(context) {
  const { request, env } = context;

  const url = new URL(request.url);
  url.hostname = env.API_ENDPOINT_URL.replace(/^https?:\/\//, '');

  return fetch(url, request);
}
