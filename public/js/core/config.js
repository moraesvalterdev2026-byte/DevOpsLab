/**
 * AXES Bank - Config Module
 * Central configuration and constants
 */

export const config = {
  // API
  api: {
    baseUrl: process.env.REACT_APP_API_URL || 'http://localhost:3000/api',
    timeout: 5000,
    retries: 3,
  },

  // App
  app: {
    name: 'AXES Bank',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
  },

  // Auth
  auth: {
    tokenKey: 'axes_token',
    userKey: 'axes_user',
    sessionTimeout: 30 * 60 * 1000, // 30 minutes
  },

  // UI
  ui: {
    toastDuration: 3000,
    modalAnimationDuration: 300,
    debounceDelay: 500,
  },

  // Features
  features: {
    darkMode: false,
    notifications: true,
    analytics: true,
  },

  // Endpoints
  endpoints: {
    auth: {
      login: '/auth/login',
      logout: '/auth/logout',
      register: '/auth/register',
      refresh: '/auth/refresh',
    },
    user: {
      profile: '/user/profile',
      update: '/user/update',
      settings: '/user/settings',
    },
    transactions: {
      list: '/transactions',
      create: '/transactions/create',
      history: '/transactions/history',
    },
  },
};

export default config;
