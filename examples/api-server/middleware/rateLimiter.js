/**
 * Rate Limiting Middleware
 */

const rateLimit = require('express-rate-limit');

// Standard rate limiter
const standardLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 60 * 60 * 1000, // 1 hour
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 1000,
  message: {
    error: 'Too many requests',
    message: 'You have exceeded the rate limit. Please try again later.',
    retryAfter: 'Check the Retry-After header'
  },
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => {
    // Skip rate limiting for health checks
    return req.path === '/health';
  }
});

// Authenticated endpoints (higher limit)
const authenticatedLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: parseInt(process.env.RATE_LIMIT_AUTH_MAX) || 5000,
  keyGenerator: (req) => {
    // Use API key or JWT token as identifier
    return req.headers.authorization || req.ip;
  },
  message: {
    error: 'Too many requests',
    message: 'You have exceeded the authenticated rate limit.'
  }
});

// Cultural knowledge endpoints (stricter limit)
const culturalKnowledgeLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: parseInt(process.env.RATE_LIMIT_CULTURAL_MAX) || 100,
  keyGenerator: (req) => {
    return req.headers.authorization || req.ip;
  },
  message: {
    error: 'Too many requests',
    message: 'Cultural knowledge endpoints have strict rate limits. Please contact api@boriken-biodiversity.org for higher limits.',
    culturalProtocol: 'These limits protect sacred and sensitive traditional knowledge.'
  }
});

// Write operations (POST, PUT, DELETE)
const writeLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  message: {
    error: 'Too many write operations',
    message: 'Please slow down your write operations.'
  }
});

module.exports = standardLimiter;
module.exports.authenticatedLimiter = authenticatedLimiter;
module.exports.culturalKnowledgeLimiter = culturalKnowledgeLimiter;
module.exports.writeLimiter = writeLimiter;
