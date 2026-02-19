/**
 * Keycloak client configuration from environment.
 * Set VITE_KEYCLOAK_URL (e.g. http://localhost:8080 or https://your-domain/api/auth),
 * VITE_KEYCLOAK_REALM (e.g. medion), and VITE_KEYCLOAK_CLIENT_ID (e.g. medion-web) in .env.
 */
const url = import.meta.env.VITE_KEYCLOAK_URL ?? 'http://localhost:8080'
const realm = import.meta.env.VITE_KEYCLOAK_REALM ?? 'medion'
const clientId = import.meta.env.VITE_KEYCLOAK_CLIENT_ID ?? 'medion-web'

export const keycloakConfig = {
	url: url.endsWith('/') ? url.slice(0, -1) : url,
	realm,
	clientId,
}
