/**
 * AXES Bank - Storage Module
 * Wrapper for localStorage with type safety and error handling
 */

export class Storage {
  /**
   * Set item in localStorage
   */
  static set(key, value, options = {}) {
    try {
      const expiration = options.ttl ? Date.now() + options.ttl : null;
      const item = {
        value,
        expiration,
        createdAt: Date.now(),
      };
      localStorage.setItem(key, JSON.stringify(item));
      return true;
    } catch (error) {
      console.error(`Storage error setting "${key}":`, error);
      return false;
    }
  }

  /**
   * Get item from localStorage
   */
  static get(key, defaultValue = null) {
    try {
      const stored = localStorage.getItem(key);
      if (!stored) return defaultValue;

      const item = JSON.parse(stored);

      // Check expiration
      if (item.expiration && item.expiration < Date.now()) {
        this.remove(key);
        return defaultValue;
      }

      return item.value;
    } catch (error) {
      console.error(`Storage error getting "${key}":`, error);
      return defaultValue;
    }
  }

  /**
   * Remove item from localStorage
   */
  static remove(key) {
    try {
      localStorage.removeItem(key);
      return true;
    } catch (error) {
      console.error(`Storage error removing "${key}":`, error);
      return false;
    }
  }

  /**
   * Clear all localStorage
   */
  static clear() {
    try {
      localStorage.clear();
      return true;
    } catch (error) {
      console.error('Storage error clearing:', error);
      return false;
    }
  }

  /**
   * Check if key exists
   */
  static has(key) {
    try {
      return localStorage.getItem(key) !== null;
    } catch (error) {
      return false;
    }
  }

  /**
   * Get all keys
   */
  static keys() {
    try {
      return Object.keys(localStorage);
    } catch (error) {
      console.error('Storage error getting keys:', error);
      return [];
    }
  }

  /**
   * Get all items as object
   */
  static getAll() {
    try {
      const items = {};
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        items[key] = this.get(key);
      }
      return items;
    } catch (error) {
      console.error('Storage error getting all:', error);
      return {};
    }
  }

  /**
   * Set multiple items
   */
  static setMultiple(items, options = {}) {
    try {
      for (const [key, value] of Object.entries(items)) {
        this.set(key, value, options);
      }
      return true;
    } catch (error) {
      console.error('Storage error setting multiple:', error);
      return false;
    }
  }

  /**
   * Remove multiple items
   */
  static removeMultiple(keys) {
    try {
      keys.forEach((key) => this.remove(key));
      return true;
    } catch (error) {
      console.error('Storage error removing multiple:', error);
      return false;
    }
  }
}

export default Storage;
