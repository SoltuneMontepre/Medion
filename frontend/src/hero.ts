import { heroui } from '@heroui/react'

// SAP / MES-style palette (Quartz-style blues + neutral grays)
const sapPrimary = {
	50: '#e8f4fc',
	100: '#d1e9fa',
	200: '#a3d3f5',
	300: '#75bdef',
	400: '#47a7e9',
	500: '#0a6ed1', // SAP Quartz primary blue
	600: '#0854a0', // SAP highlight/selected
	700: '#063b70',
	800: '#042240',
	900: '#021118',
	foreground: '#ffffff',
	DEFAULT: '#0a6ed1',
}

const sapNeutral = {
	50: '#f7f7f8',
	100: '#eef0f1',
	200: '#e5e5e5',
	300: '#d5d7d9',
	400: '#89919a',
	500: '#6b7380',
	600: '#475e75',
	700: '#32363a',
	800: '#223548',
	900: '#11181c',
	foreground: '#11181c',
	DEFAULT: '#6b7380',
}

export default heroui({
	defaultTheme: 'light',
	defaultExtendTheme: 'light',
	layout: {
		radius: {
			small: '0.25rem',
			medium: '0.375rem',
			large: '0.5rem',
		},
		borderWidth: {
			small: '1px',
			medium: '1px',
			large: '2px',
		},
	},
	themes: {
		light: {
			extend: 'light',
			layout: {
				radius: {
					small: '0.25rem',
					medium: '0.375rem',
					large: '0.5rem',
				},
			},
			colors: {
				background: { DEFAULT: '#f7f7f8' },
				foreground: { ...sapNeutral, DEFAULT: '#223548' },
				primary: sapPrimary,
				secondary: {
					...sapNeutral,
					DEFAULT: sapNeutral[600],
					foreground: '#ffffff',
				},
				content1: { DEFAULT: '#ffffff', foreground: '#223548' },
				content2: { DEFAULT: sapNeutral[100], foreground: sapNeutral[800] },
				content3: { DEFAULT: sapNeutral[200], foreground: sapNeutral[700] },
				content4: { DEFAULT: sapNeutral[300], foreground: sapNeutral[600] },
				focus: { DEFAULT: '#0a6ed1' },
				divider: { DEFAULT: 'rgba(34, 53, 72, 0.12)' },
			},
		},
		dark: {
			extend: 'dark',
			layout: {
				radius: {
					small: '0.25rem',
					medium: '0.375rem',
					large: '0.5rem',
				},
			},
			colors: {
				background: { DEFAULT: '#0d1117' },
				foreground: { DEFAULT: '#eef0f1' },
				primary: sapPrimary,
				secondary: {
					...sapNeutral,
					DEFAULT: sapNeutral[500],
					foreground: '#ffffff',
				},
				content1: { DEFAULT: '#161b22', foreground: '#eef0f1' },
				content2: { DEFAULT: '#21262d', foreground: sapNeutral[200] },
				content3: { DEFAULT: '#30363d', foreground: sapNeutral[300] },
				content4: { DEFAULT: '#484f58', foreground: sapNeutral[400] },
				focus: { DEFAULT: '#47a7e9' },
				divider: { DEFAULT: 'rgba(238, 240, 241, 0.12)' },
			},
		},
	},
})
