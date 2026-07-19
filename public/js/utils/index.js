/**
 * AXES Bank - Utility Functions
 * General purpose utilities for common operations
 */

/**
 * Format currency for Brazilian Real
 */
export function formatCurrency(value) {
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
  }).format(value);
}

/**
 * Format date and time
 */
export function formatDate(date, locale = 'pt-BR') {
  return new Intl.DateTimeFormat(locale, {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  }).format(new Date(date));
}

export function formatDateTime(date, locale = 'pt-BR') {
  return new Intl.DateTimeFormat(locale, {
    year: 'numeric',
    month: 'numeric',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(new Date(date));
}

/**
 * Format CPF
 */
export function formatCPF(cpf) {
  const cleaned = cpf.replace(/\D/g, '');
  return cleaned.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
}

/**
 * Validate CPF
 */
export function isValidCPF(cpf) {
  const cleaned = cpf.replace(/\D/g, '');
  if (cleaned.length !== 11 || /^(\d)\1{10}$/.test(cleaned)) {
    return false;
  }

  let sum = 0;
  let remainder;

  for (let i = 1; i <= 9; i++) {
    sum += parseInt(cleaned.substring(i - 1, i)) * (11 - i);
  }

  remainder = (sum * 10) % 11;
  if (remainder === 10 || remainder === 11) remainder = 0;
  if (remainder !== parseInt(cleaned.substring(9, 10))) return false;

  sum = 0;
  for (let i = 1; i <= 10; i++) {
    sum += parseInt(cleaned.substring(i - 1, i)) * (12 - i);
  }

  remainder = (sum * 10) % 11;
  if (remainder === 10 || remainder === 11) remainder = 0;
  if (remainder !== parseInt(cleaned.substring(10, 11))) return false;

  return true;
}

/**
 * Validate email
 */
export function isValidEmail(email) {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email);
}

/**
 * Validate password strength
 */
export function validatePasswordStrength(password) {
  const strength = {
    score: 0,
    feedback: [],
  };

  if (password.length >= 8) strength.score++;
  else strength.feedback.push('Mínimo 8 caracteres');

  if (password.length >= 12) strength.score++;
  else strength.feedback.push('Use 12+ caracteres para força máxima');

  if (/[a-z]/.test(password)) strength.score++;
  else strength.feedback.push('Adicione letras minúsculas');

  if (/[A-Z]/.test(password)) strength.score++;
  else strength.feedback.push('Adicione letras maiúsculas');

  if (/\d/.test(password)) strength.score++;
  else strength.feedback.push('Adicione números');

  if (/[!@#$%^&*]/.test(password)) strength.score++;
  else strength.feedback.push('Adicione caracteres especiais');

  return strength;
}

/**
 * Debounce function
 */
export function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

/**
 * Throttle function
 */
export function throttle(func, limit) {
  let inThrottle;
  return function (...args) {
    if (!inThrottle) {
      func.apply(this, args);
      inThrottle = true;
      setTimeout(() => (inThrottle = false), limit);
    }
  };
}

/**
 * Deep clone object
 */
export function deepClone(obj) {
  return JSON.parse(JSON.stringify(obj));
}

/**
 * Merge objects
 */
export function mergeObjects(...objects) {
  return Object.assign({}, ...objects);
}

/**
 * Get nested property
 */
export function getNestedValue(obj, path, defaultValue = null) {
  const keys = path.split('.');
  let result = obj;

  for (const key of keys) {
    if (result && typeof result === 'object' && key in result) {
      result = result[key];
    } else {
      return defaultValue;
    }
  }

  return result;
}

/**
 * Set nested property
 */
export function setNestedValue(obj, path, value) {
  const keys = path.split('.');
  const lastKey = keys.pop();
  let current = obj;

  for (const key of keys) {
    if (!(key in current)) {
      current[key] = {};
    }
    current = current[key];
  }

  current[lastKey] = value;
  return obj;
}

/**
 * Check if object is empty
 */
export function isEmpty(obj) {
  return Object.keys(obj).length === 0;
}

/**
 * Check if value is null or undefined
 */
export function isNil(value) {
  return value === null || value === undefined;
}

/**
 * Array utilities
 */
export const arrayUtils = {
  unique: (arr) => [...new Set(arr)],
  flatten: (arr) => arr.flat(Infinity),
  shuffle: (arr) => [...arr].sort(() => Math.random() - 0.5),
  chunk: (arr, size) => {
    const chunks = [];
    for (let i = 0; i < arr.length; i += size) {
      chunks.push(arr.slice(i, i + size));
    }
    return chunks;
  },
  first: (arr) => arr[0],
  last: (arr) => arr[arr.length - 1],
};

/**
 * Wait/sleep utility
 */
export function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Retry function
 */
export async function retry(fn, options = {}) {
  const { maxAttempts = 3, delay = 1000, backoff = 2 } = options;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxAttempts) throw error;
      await wait(delay * Math.pow(backoff, attempt - 1));
    }
  }
}

export default {
  formatCurrency,
  formatDate,
  formatDateTime,
  formatCPF,
  isValidCPF,
  isValidEmail,
  validatePasswordStrength,
  debounce,
  throttle,
  deepClone,
  mergeObjects,
  getNestedValue,
  setNestedValue,
  isEmpty,
  isNil,
  arrayUtils,
  wait,
  retry,
};
