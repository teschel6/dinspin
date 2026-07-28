export const apiUrl =
  window.__APP_CONFIG__?.API_URL || import.meta.env.VITE_API_URL || 'http://localhost:8000'
