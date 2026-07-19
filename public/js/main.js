/**
 * AXES Bank - Main App Entry Point
 * Initializes the application, sets up event listeners, and bootstraps modules
 */

import { config, apiClient, logger, Storage } from './core/index.js';
import * as utils from './utils/index.js';

class AxesBankApp {
  constructor() {
    this.initialized = false;
    this.modules = {};
    logger.info('AXES Bank App inicializando...');
  }

  /**
   * Initialize application
   */
  async init() {
    try {
      logger.group('App Initialization');

      // Check browser support
      this.checkBrowserSupport();
      logger.log('✓ Browser support verificado');

      // Setup storage cleanup
      this.setupStorageCleanup();
      logger.log('✓ Storage setup completo');

      // Initialize event listeners
      this.setupGlobalEventListeners();
      logger.log('✓ Event listeners configurados');

      // Check authentication status
      await this.checkAuthStatus();
      logger.log('✓ Status de autenticação verificado');

      // Setup theme
      this.setupTheme();
      logger.log('✓ Tema configurado');

      // Setup responsive listeners
      this.setupResponsiveListeners();
      logger.log('✓ Listeners responsivos configurados');

      logger.groupEnd();

      this.initialized = true;
      logger.info('✓ Aplicação inicializada com sucesso');
      document.dispatchEvent(new CustomEvent('app:ready'));
    } catch (error) {
      logger.error('Erro ao inicializar aplicação', error);
      this.showFatalError();
    }
  }

  /**
   * Check browser support
   */
  checkBrowserSupport() {
    const required = ['localStorage', 'fetch', 'Promise', 'Symbol'];
    const unsupported = required.filter((api) => !(api in window));

    if (unsupported.length > 0) {
      throw new Error(`Browser não suporta: ${unsupported.join(', ')}`);
    }
  }

  /**
   * Setup storage cleanup on first visit
   */
  setupStorageCleanup() {
    const lastCleanup = Storage.get('_lastStorageCleanup');
    const now = Date.now();

    // Cleanup every 24 hours
    if (!lastCleanup || now - lastCleanup > 24 * 60 * 60 * 1000) {
      Storage.set('_lastStorageCleanup', now);
      // Add cleanup logic if needed
    }
  }

  /**
   * Setup global event listeners
   */
  setupGlobalEventListeners() {
    // Handle unauthorized access
    window.addEventListener('auth:unauthorized', () => {
      logger.warn('Acesso não autorizado - redirecionando para login');
      window.location.href = '/login';
    });

    // Handle API errors
    window.addEventListener('api:error', (event) => {
      const { error } = event.detail;
      logger.error('API Error:', error);
      this.showErrorToast(error.message || 'Erro na requisição');
    });

    // Handle network offline
    window.addEventListener('offline', () => {
      logger.warn('Conexão offline detectada');
      this.showWarningToast('Você está offline');
    });

    // Handle network online
    window.addEventListener('online', () => {
      logger.info('Conexão online restabelecida');
      this.showSuccessToast('Conexão restabelecida');
    });

    // Handle unhandled errors
    window.addEventListener('error', (event) => {
      logger.error('Unhandled error:', event.error);
    });

    // Handle unhandled promise rejections
    window.addEventListener('unhandledrejection', (event) => {
      logger.error('Unhandled promise rejection:', event.reason);
      event.preventDefault();
    });

    // Handle visibility changes
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) {
        logger.log('App hidden');
      } else {
        logger.log('App visible');
      }
    });
  }

  /**
   * Check authentication status
   */
  async checkAuthStatus() {
    try {
      const user = Storage.get(config.auth.userKey);
      const token = apiClient.getToken();

      if (!user || !token) {
        // Not authenticated
        return false;
      }

      // Verify token is still valid by making a request
      try {
        await apiClient.get(config.endpoints.user.profile);
        return true;
      } catch (error) {
        // Token invalid or expired
        apiClient.clearToken();
        Storage.remove(config.auth.userKey);
        return false;
      }
    } catch (error) {
      logger.error('Error checking auth status:', error);
      return false;
    }
  }

  /**
   * Setup theme (light/dark)
   */
  setupTheme() {
    const themeToggle = document.getElementById('theme-toggle');
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

    const currentTheme = Storage.get('theme') || (prefersDark ? 'dark' : 'light');

    // Apply theme
    this.applyTheme(currentTheme);

    // Setup toggle button
    if (themeToggle) {
      themeToggle.addEventListener('click', () => {
        const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
        this.applyTheme(newTheme);
        Storage.set('theme', newTheme);
      });
    }
  }

  /**
   * Apply theme
   */
  applyTheme(theme) {
    if (theme === 'dark') {
      document.documentElement.style.colorScheme = 'dark';
      document.body.classList.add('dark-mode');
    } else {
      document.documentElement.style.colorScheme = 'light';
      document.body.classList.remove('dark-mode');
    }
  }

  /**
   * Setup responsive listeners
   */
  setupResponsiveListeners() {
    // Mobile menu toggle
    const mobileMenuBtn = document.querySelector('[data-mobile-menu-toggle]');
    if (mobileMenuBtn) {
      mobileMenuBtn.addEventListener('click', () => {
        const nav = document.querySelector('nav');
        nav?.classList.toggle('open');
      });
    }

    // Close mobile menu on navigation
    document.querySelectorAll('nav a').forEach((link) => {
      link.addEventListener('click', () => {
        const nav = document.querySelector('nav');
        nav?.classList.remove('open');
      });
    });
  }

  /**
   * Show toast notification
   */
  showToast(message, type = 'info', duration = config.ui.toastDuration) {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = `toast toast-${type} animate-fade-in-up`;
    toast.setAttribute('role', 'alert');
    toast.textContent = message;

    container.appendChild(toast);

    setTimeout(() => {
      toast.classList.add('animate-fade-out');
      setTimeout(() => toast.remove(), 300);
    }, duration);
  }

  showSuccessToast(message) {
    this.showToast(message, 'success');
  }

  showErrorToast(message) {
    this.showToast(message, 'error');
  }

  showWarningToast(message) {
    this.showToast(message, 'warning');
  }

  showInfoToast(message) {
    this.showToast(message, 'info');
  }

  /**
   * Show fatal error
   */
  showFatalError() {
    const errorDiv = document.createElement('div');
    errorDiv.className = 'alert alert-error mx-auto mt-8';
    errorDiv.innerHTML = `
      <strong>Erro Fatal</strong>
      <p>A aplicação encontrou um erro e não pode continuar. Por favor, recarregue a página.</p>
    `;
    document.body.insertBefore(errorDiv, document.body.firstChild);
  }

  /**
   * Get module
   */
  getModule(name) {
    return this.modules[name];
  }

  /**
   * Register module
   */
  registerModule(name, module) {
    this.modules[name] = module;
    logger.log(`Module registered: ${name}`);
  }
}

// Create and initialize app
const app = new AxesBankApp();

// Export globally
window.AxesBank = {
  app,
  apiClient,
  logger,
  Storage,
  utils,
  config,
};

// Initialize on DOM ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => app.init());
} else {
  app.init();
}

export default app;
