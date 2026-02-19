export interface LoginRequest {
	userNameOrEmail: string
	password: string
}

export interface RegisterUserRequest {
	email: string
	userName: string
	password: string
	firstName: string
	lastName: string
	phoneNumber?: string
	department?: string
}

export interface AuthToken {
	accessToken: string
	expiresIn: number
}

export interface User {
	id: string
	email: string
	userName: string
	firstName: string
	lastName: string
	phoneNumber?: string
	emailConfirmed: boolean
	phoneNumberConfirmed: boolean
	isActive: boolean
	department?: string
	profilePictureUrl?: string
	createdAt: string
	roles: string[]
}
