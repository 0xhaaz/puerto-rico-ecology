/**
 * Global Error Handler Middleware
 */

const logger = require('../utils/logger');

const errorHandler = (err, req, res, next) => {
  // Log error
  logger.error('Error occurred:', {
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
    ip: req.ip
  });

  // Default error status
  let status = err.status || err.statusCode || 500;
  let message = err.message || 'Internal Server Error';

  // Handle specific error types
  if (err.name === 'ValidationError') {
    status = 400;
    message = 'Validation Error';
  } else if (err.name === 'UnauthorizedError' || err.name === 'JsonWebTokenError') {
    status = 401;
    message = 'Unauthorized';
  } else if (err.code === '23505') {
    // PostgreSQL unique violation
    status = 409;
    message = 'Resource already exists';
  } else if (err.code === '23503') {
    // PostgreSQL foreign key violation
    status = 400;
    message = 'Referenced resource does not exist';
  } else if (err.code === 'ECONNREFUSED') {
    status = 503;
    message = 'Database connection failed';
  }

  // Prepare error response
  const errorResponse = {
    error: {
      status,
      message,
      ...(process.env.NODE_ENV === 'development' && {
        stack: err.stack,
        details: err.details || {}
      })
    },
    timestamp: new Date().toISOString(),
    path: req.path
  };

  res.status(status).json(errorResponse);
};

module.exports = errorHandler;
