/**
 * Borikén Biodiversity API Server
 *
 * REST API for Puerto Rico's biodiversity data with:
 * - Cultural protocol compliance (FPIC)
 * - Environmental justice framework
 * - Web3 integration
 * - PostGIS spatial queries
 *
 * @version 1.0.0
 * @license MIT
 */

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');

// Middleware
const rateLimiter = require('./middleware/rateLimiter');
const errorHandler = require('./middleware/errorHandler');
const culturalProtocol = require('./middleware/culturalProtocol');
const logger = require('./utils/logger');

// Routes
const speciesRoutes = require('./routes/species');
const ecosystemRoutes = require('./routes/ecosystems');
const observationRoutes = require('./routes/observations');
const culturalKnowledgeRoutes = require('./routes/culturalKnowledge');
const conservationRoutes = require('./routes/conservation');
const justiceRoutes = require('./routes/justice');
const web3Routes = require('./routes/web3');

// Database connection
const db = require('./config/database');

const app = express();
const PORT = process.env.PORT || 3000;

// =====================================================
// SWAGGER / OPENAPI CONFIGURATION
// =====================================================

const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Borikén Biodiversity API',
      version: '1.0.0',
      description: `
# Borikén (Puerto Rico) Biodiversity API

Comprehensive REST API for accessing biodiversity data with cultural protocols and justice framework.

## Features

- **5,847+ Species**: Comprehensive database with endemic and conservation status
- **Cultural Protocols**: FPIC compliance for traditional knowledge
- **Environmental Justice**: Mapping sacrifice zones and vulnerable communities
- **PostGIS Spatial Queries**: Geographic searches and mapping
- **Web3 Integration**: NFT metadata, DAO governance, conservation tokens
- **Time-Series Data**: Population trends and conservation metrics

## Authentication

Most endpoints require an API key. Include it in your requests:

\`\`\`
Authorization: Bearer YOUR_API_KEY
\`\`\`

Cultural knowledge endpoints require additional community approval.

## Rate Limits

- Public endpoints: 1000 requests/hour
- Authenticated endpoints: 5000 requests/hour
- Cultural knowledge: 100 requests/hour (with approval)

## Data Sovereignty

This data is governed by Indigenous Data Sovereignty principles.
Commercial use requires community consent and benefit sharing.
      `,
      contact: {
        name: 'API Support',
        email: 'api@boriken-biodiversity.org'
      },
      license: {
        name: 'MIT',
        url: 'https://opensource.org/licenses/MIT'
      }
    },
    servers: [
      {
        url: 'http://localhost:3000/api/v1',
        description: 'Development server'
      },
      {
        url: 'https://api.boriken-biodiversity.org/api/v1',
        description: 'Production server'
      }
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT'
        },
        web3Wallet: {
          type: 'apiKey',
          in: 'header',
          name: 'X-Wallet-Address'
        }
      }
    },
    tags: [
      { name: 'Species', description: 'Species information and queries' },
      { name: 'Ecosystems', description: 'Habitat and ecosystem data' },
      { name: 'Observations', description: 'Citizen science observations' },
      { name: 'Cultural Knowledge', description: 'Traditional ecological knowledge (FPIC protected)' },
      { name: 'Conservation', description: 'Conservation status and actions' },
      { name: 'Justice', description: 'Environmental and climate justice data' },
      { name: 'Web3', description: 'Blockchain and NFT integration' }
    ]
  },
  apis: ['./routes/*.js']
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);

// =====================================================
// MIDDLEWARE CONFIGURATION
// =====================================================

// Security
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", 'data:', 'https:']
    }
  }
}));

// CORS
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Wallet-Address'],
  credentials: true,
  maxAge: 86400 // 24 hours
};
app.use(cors(corsOptions));

// Compression
app.use(compression());

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging
if (process.env.NODE_ENV === 'production') {
  app.use(morgan('combined', { stream: logger.stream }));
} else {
  app.use(morgan('dev'));
}

// Rate limiting
app.use('/api/', rateLimiter);

// Cultural protocol middleware (adds required disclaimers)
app.use('/api/', culturalProtocol);

// =====================================================
// API DOCUMENTATION
// =====================================================

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'Borikén Biodiversity API Documentation'
}));

// Serve swagger spec as JSON
app.get('/api-docs.json', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.send(swaggerSpec);
});

// =====================================================
// ROOT ENDPOINT
// =====================================================

app.get('/', (req, res) => {
  res.json({
    name: 'Borikén Biodiversity API',
    version: '1.0.0',
    description: 'REST API for Puerto Rico\'s biodiversity with cultural protocols',
    documentation: '/api-docs',
    endpoints: {
      species: '/api/v1/species',
      ecosystems: '/api/v1/ecosystems',
      observations: '/api/v1/observations',
      culturalKnowledge: '/api/v1/cultural',
      conservation: '/api/v1/conservation',
      justice: '/api/v1/justice',
      web3: '/api/v1/web3'
    },
    culturalAcknowledgment: 'This knowledge belongs to the Indigenous peoples of Borikén and their descendants',
    dataGovernance: 'Indigenous Data Sovereignty principles',
    status: 'operational',
    timestamp: new Date().toISOString()
  });
});

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    // Check database connection
    await db.query('SELECT 1');

    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      database: 'connected',
      memory: process.memoryUsage()
    });
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      database: 'disconnected',
      error: error.message
    });
  }
});

// =====================================================
// API ROUTES
// =====================================================

const API_VERSION = '/api/v1';

app.use(`${API_VERSION}/species`, speciesRoutes);
app.use(`${API_VERSION}/ecosystems`, ecosystemRoutes);
app.use(`${API_VERSION}/observations`, observationRoutes);
app.use(`${API_VERSION}/cultural`, culturalKnowledgeRoutes);
app.use(`${API_VERSION}/conservation`, conservationRoutes);
app.use(`${API_VERSION}/justice`, justiceRoutes);
app.use(`${API_VERSION}/web3`, web3Routes);

// =====================================================
// ERROR HANDLING
// =====================================================

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.path} not found`,
    documentation: '/api-docs'
  });
});

// Global error handler
app.use(errorHandler);

// =====================================================
// SERVER STARTUP
// =====================================================

const server = app.listen(PORT, () => {
  logger.info(`🌴 Borikén Biodiversity API server running on port ${PORT}`);
  logger.info(`📚 API Documentation: http://localhost:${PORT}/api-docs`);
  logger.info(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  logger.info(`🔐 CORS enabled for: ${corsOptions.origin}`);
  logger.info(`\n🦜 Protecting 5,847+ species of Borikén`);
  logger.info(`🌿 Honoring Indigenous Data Sovereignty`);
  logger.info(`⚖️  Advancing Environmental Justice\n`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    logger.info('HTTP server closed');
    db.end(() => {
      logger.info('Database connection closed');
      process.exit(0);
    });
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT signal received: closing HTTP server');
  server.close(() => {
    logger.info('HTTP server closed');
    db.end(() => {
      logger.info('Database connection closed');
      process.exit(0);
    });
  });
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  logger.error('Unhandled Promise Rejection:', err);
  // Close server & exit process
  server.close(() => process.exit(1));
});

module.exports = app;
