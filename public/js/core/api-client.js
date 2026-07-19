/**
 * AXES Bank - API Client Module
 * Centralized HTTP client with interceptors and error handling
 */

import config from './config.js';

class APIClient {
  constructor() {
    this.baseUrl = config.api.baseUrl;
    this.timeout = config.api.timeout;
    this.retries = config.api.retries;
    this.token = this.getToken();
  }

  /**
   * Get auth token from storage
   */
  getToken() {
    try {
      const stored = localStorage.getItem(config.auth.tokenKey);
      return stored ? JSON.parse(stored) : null;
    } catch (e) {
      console.error('Error reading token from storage:', e);
      return null;
    }
  }

  /**
   * Set auth token in storage
   */
  setToken(token) {
    try {
      this.token = token;
      localStorage.setItem(config.auth.tokenKey, JSON.stringify(token));
    } catch (e) {
      console.error('Error writing token to storage:', e);
    }
  }

  /**
   * Clear auth token
   */
  clearToken() {
    this.token = null;
    localStorage.removeItem(config.auth.tokenKey);
    localStorage.removeItem(config.auth.userKey);
  }

  /**
   * Get default headers
   */
  getHeaders() {
    const headers = {
      'Content-Type': 'application/json',
      'X-Request-ID': this.generateRequestId(),
    };

    if (this.token) {
      headers.Authorization = `Bearer ${this.token}`;
    }

    return headers;
  }

  /**
   * Generate unique request ID
   */
  generateRequestId() {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Create abort controller with timeout
   */
  createController() {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout);
    return { controller, timeoutId };
  }

  /**
   * Perform fetch with retry logic
   */
  async fetchWithRetry(url, options, attempt = 1) {
    try {
      const { controller, timeoutId } = this.createController();
      const response = await fetch(url, {
        ...options,
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        throw new APIError(
          `HTTP ${response.status}: ${response.statusText}`,
          response.status,
          response
        );
      }

      return response;
    } catch (error) {
      if (attempt < this.retries && this.isRetryableError(error)) {
        const delay = Math.pow(2, attempt - 1) * 1000;
        await this.delay(delay);
        return this.fetchWithRetry(url, options, attempt + 1);
      }
      throw error;
    }
  }

  /**
   * Check if error is retryable
   */
  isRetryableError(error) {
    return (
      error.name === 'AbortError' ||
      (error instanceof APIError && error.status >= 500)
    );
  }

  /**
   * Delay utility
   */
  delay(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  /**
   * Request helper
   */
  async request(url, options = {}) {
    const fullUrl = url.startsWith('http') ? url : `${this.baseUrl}${url}`;
    const mergedOptions = {
      ...options,
      headers: {
        ...this.getHeaders(),
        ...options.headers,
      },
    };

    try {
      const response = await this.fetchWithRetry(fullUrl, mergedOptions);
      const data = await response.json();
      return data;
    } catch (error) {
      if (error instanceof APIError && error.status === 401) {
        this.clearToken();
        window.dispatchEvent(new CustomEvent('auth:unauthorized'));
      }
      throw error;
    }
  }

  // HTTP Methods
  get(url, options = {}) {
    return this.request(url, { method: 'GET', ...options });
  }

  post(url, data = {}, options = {}) {
    return this.request(url, {
      method: 'POST',
      body: JSON.stringify(data),
      ...options,
    });
  }

  put(url, data = {}, options = {}) {
    return this.request(url, {
      method: 'PUT',
      body: JSON.stringify(data),
      ...options,
    });
  }

  patch(url, data = {}, options = {}) {
    return this.request(url, {
      method: 'PATCH',
      body: JSON.stringify(data),
      ...options,
    });
  }

  delete(url, options = {}) {
    return this.request(url, { method: 'DELETE', ...options });
  }
}

/**
 * Custom API Error class
 */
class APIError extends Error {
  constructor(message, status, response) {
    super(message);
    this.name = 'APIError';
    this.status = status;
    this.response = response;
  }
}

export const apiClient = new APIClient();
export default apiClient;
