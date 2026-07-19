/**
 * AXES Bank - Logger Module
 * Centralized logging with levels and environment awareness
 */

export class Logger {
  constructor(options = {}) {
    this.environment = options.environment || 'development';
    this.isDevelopment = this.environment === 'development';
    this.logLevel = options.logLevel || 'info';
    this.prefix = options.prefix || '[AXES]';
  }

  /**
   * Format log message
   */
  formatMessage(level, message, data = {}) {
    const timestamp = new Date().toISOString();
    const dataStr = Object.keys(data).length > 0 ? JSON.stringify(data) : '';
    return `${timestamp} [${level.toUpperCase()}] ${this.prefix} ${message} ${dataStr}`;
  }

  /**
   * Log at different levels
   */
  log(message, data = {}) {
    if (this.isDevelopment) {
      console.log(this.formatMessage('log', message, data));
    }
  }

  info(message, data = {}) {
    console.info(this.formatMessage('info', message, data));
  }

  warn(message, data = {}) {
    console.warn(this.formatMessage('warn', message, data));
  }

  error(message, error = null, data = {}) {
    const errorData = {
      ...data,
      ...(error && {
        errorName: error.name,
        errorMessage: error.message,
        errorStack: error.stack,
      }),
    };
    console.error(this.formatMessage('error', message, errorData));
  }

  debug(message, data = {}) {
    if (this.isDevelopment) {
      console.debug(this.formatMessage('debug', message, data));
    }
  }

  /**
   * Group logs
   */
  group(label) {
    console.group(`${this.prefix} ${label}`);
  }

  groupEnd() {
    console.groupEnd();
  }

  /**
   * Measure performance
   */
  time(label) {
    console.time(`${this.prefix} ${label}`);
  }

  timeEnd(label) {
    console.timeEnd(`${this.prefix} ${label}`);
  }

  /**
   * Table logging
   */
  table(data) {
    console.table(data);
  }

  /**
   * Assert condition
   */
  assert(condition, message, data = {}) {
    console.assert(condition, this.formatMessage('assert', message, data));
  }

  /**
   * Clear console
   */
  clear() {
    console.clear();
  }
}

export const logger = new Logger({
  environment: process.env.NODE_ENV || 'development',
  prefix: '[AXES Bank]',
});

export default logger;
