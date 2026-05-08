export const cookies = {
  /**
   * Get default cookie options with security settings
   * @param {Object} overrides - Options to override defaults
   * @returns {Object} Cookie options object
   */
  getOptions: (overrides = {}) => ({
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'Strict',
    path: '/',
    maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days in milliseconds
    ...overrides,
  }),

  /**
   * Set a cookie in the response
   * @param {Object} res - Express response object
   * @param {string} name - Cookie name
   * @param {string} value - Cookie value
   * @param {Object} options - Additional options to override defaults
   */
  set: (res, name, value, options = {}) => {
    const cookieOptions = cookies.getOptions(options);
    res.cookie(name, value, cookieOptions);
  },

  /**
   * Clear/delete a cookie from the response
   * @param {Object} res - Express response object
   * @param {string} name - Cookie name to clear
   * @param {Object} options - Additional options (should match set() options)
   */
  clear: (res, name, options = {}) => {
    const cookieOptions = cookies.getOptions({
      ...options,
      maxAge: 0,
    });
    res.clearCookie(name, cookieOptions);
  },

  /**
   * Get a cookie value from the request
   * @param {Object} req - Express request object
   * @param {string} name - Cookie name
   * @returns {string|undefined} Cookie value or undefined
   */
  get: (req, name) => {
    return req.cookies?.[name];
  },
};