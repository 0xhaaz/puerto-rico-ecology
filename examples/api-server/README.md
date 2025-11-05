# Borikén Biodiversity REST API

A comprehensive REST API for accessing Puerto Rico's biodiversity data with cultural protocols, environmental justice framework, and Web3 integration.

## Features

- **5,847+ Species Database**: Complete biodiversity information
- **PostGIS Spatial Queries**: Geographic searches and mapping
- **Cultural Protocols**: FPIC compliance for traditional knowledge
- **Environmental Justice**: Sacrifice zones and vulnerable communities
- **Web3 Integration**: NFT metadata, DAO governance, conservation tokens
- **Time-Series Data**: Population trends and conservation metrics
- **Rate Limiting**: Protect sensitive endpoints
- **Comprehensive Documentation**: OpenAPI/Swagger documentation

## Quick Start

### Prerequisites

- Node.js 18+
- PostgreSQL 14+ with PostGIS extension
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Edit .env with your database credentials
nano .env

# Start development server
npm run dev
```

The server will start at `http://localhost:3000`

API Documentation available at: `http://localhost:3000/api-docs`

### Database Setup

1. Create PostgreSQL database:
```bash
createdb boriken_biodiversity
```

2. Enable PostGIS:
```sql
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
```

3. Load schema:
```bash
psql -d boriken_biodiversity -f ../../schemas/postgresql_schema.sql
```

4. Load sample data (optional):
```bash
node scripts/load-sample-data.js
```

## API Endpoints

### Species (`/api/v1/species`)

- `GET /` - List all species with filtering
- `GET /:id` - Get species by ID
- `GET /endemic/list` - Get endemic species only
- `GET /endangered/list` - Get endangered species with habitats
- `GET /search/near` - Find species near a location (PostGIS)
- `GET /:id/population-trend` - Get population time-series
- `GET /stats/biodiversity` - Biodiversity statistics

#### Example Request

```bash
curl "http://localhost:3000/api/v1/species?endemic_status=endemic_puerto_rico&limit=10"
```

#### Example Response

```json
{
  "data": [
    {
      "id": "uuid",
      "common_name": "Puerto Rican Parrot",
      "taino_name": "Iguaca",
      "scientific_name": "Amazona vittata",
      "conservation_status": "critically_endangered",
      "endemic_status": "endemic_puerto_rico",
      "rarity_score": 98.0,
      "cultural_value": 95.0
    }
  ],
  "pagination": {
    "limit": 10,
    "offset": 0,
    "total": 309,
    "hasMore": true
  },
  "_cultural_protocol": {
    "acknowledgment": "This knowledge belongs to the Indigenous peoples of Borikén and their descendants"
  }
}
```

### Ecosystems (`/api/v1/ecosystems`)

- `GET /` - List ecosystems with filtering
- `GET /:id` - Get ecosystem details with species count

### Observations (`/api/v1/observations`)

- `GET /` - Get recent observations (citizen science)
- `POST /` - Submit new observation

#### Submit Observation

```bash
curl -X POST http://localhost:3000/api/v1/observations \
  -H "Content-Type: application/json" \
  -d '{
    "species_id": "uuid",
    "latitude": 18.3,
    "longitude": -65.9,
    "observation_date": "2025-11-05",
    "observer_name": "Maria Rodriguez",
    "individual_count": 2
  }'
```

### Cultural Knowledge (`/api/v1/cultural`) - FPIC Protected

- `GET /` - Get public cultural knowledge only

**Note**: Sacred and restricted knowledge requires authentication and community approval.

Rate limit: 100 requests/hour

### Conservation (`/api/v1/conservation`)

- `GET /actions` - Conservation actions and projects
- `GET /invasive-species` - Invasive species tracking

### Justice (`/api/v1/justice`)

- `GET /sacrifice-zones` - Environmental justice communities
- `GET /food-systems` - Food sovereignty data
- `GET /economic-ecology` - Economic ecology metrics

#### Sacrifice Zones Example

```bash
curl "http://localhost:3000/api/v1/justice/sacrifice-zones"
```

Returns communities with disproportionate environmental burdens:
- Pollution exposure
- Hurricane Maria recovery inequities
- Demographics and poverty rates
- Community organizing efforts

### Web3 (`/api/v1/web3`)

- `GET /nft-ready-species` - Species with NFT metadata
- `GET /dao-proposals` - DAO governance proposals
- `GET /rewards/:wallet_address` - Conservation token rewards

## Authentication

Most endpoints are public. Restricted endpoints require authentication:

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  http://localhost:3000/api/v1/cultural
```

## Rate Limits

- Public endpoints: **1000 requests/hour**
- Authenticated endpoints: **5000 requests/hour**
- Cultural knowledge: **100 requests/hour** (with approval)

Rate limit headers:
- `X-RateLimit-Limit`: Total requests allowed
- `X-RateLimit-Remaining`: Requests remaining
- `X-RateLimit-Reset`: Time when limit resets

## Cultural Protocols

All responses include cultural protocol metadata:

```json
{
  "_cultural_protocol": {
    "acknowledgment": "This knowledge belongs to the Indigenous peoples of Borikén and their descendants",
    "fpic_status": "Free, Prior, and Informed Consent required for commercial use",
    "attribution_required": true,
    "data_sovereignty": "Governed by Indigenous Data Sovereignty principles"
  }
}
```

### FPIC Compliance

- Traditional knowledge requires Free, Prior, and Informed Consent
- Commercial use requires community consent
- 50% of benefits must be shared with knowledge holders
- Sacred knowledge is protected and restricted

## Spatial Queries (PostGIS)

### Find Species Near Location

```bash
curl "http://localhost:3000/api/v1/species/search/near?latitude=18.3&longitude=-65.9&radius_km=10"
```

Returns all species observed within 10km of the coordinates.

## Error Handling

All errors return consistent format:

```json
{
  "error": {
    "status": 404,
    "message": "Species not found"
  },
  "timestamp": "2025-11-05T12:00:00.000Z",
  "path": "/api/v1/species/invalid-id"
}
```

Common status codes:
- `400` - Bad Request (validation error)
- `401` - Unauthorized
- `403` - Forbidden (cultural protocol violation)
- `404` - Not Found
- `429` - Too Many Requests (rate limit)
- `500` - Internal Server Error

## Environment Variables

See `.env.example` for all configuration options:

```bash
# Server
NODE_ENV=development
PORT=3000

# Database
DB_HOST=localhost
DB_NAME=boriken_biodiversity
DB_USER=biodiv_api
DB_PASSWORD=your_password

# Authentication
JWT_SECRET=your_secret
API_KEY_HEADER=X-API-Key

# Rate Limiting
RATE_LIMIT_MAX_REQUESTS=1000
RATE_LIMIT_CULTURAL_MAX=100

# Web3
WEB3_PROVIDER_URL=https://mainnet.base.org
NFT_CONTRACT_ADDRESS=0x...
```

## Development

```bash
# Development with auto-reload
npm run dev

# Run tests
npm test

# Lint code
npm run lint

# Format code
npm run format
```

## Production Deployment

```bash
# Build for production
npm install --production

# Start production server
NODE_ENV=production npm start
```

### Production Checklist

- [ ] Set `NODE_ENV=production`
- [ ] Use strong `JWT_SECRET`
- [ ] Configure `ALLOWED_ORIGINS` for CORS
- [ ] Set up SSL/TLS certificates
- [ ] Configure proper database credentials
- [ ] Set up monitoring and logging
- [ ] Configure backup systems
- [ ] Review rate limits
- [ ] Test cultural protocol compliance

## Architecture

```
api-server/
├── server.js              # Main server file
├── config/
│   └── database.js        # PostgreSQL connection
├── middleware/
│   ├── rateLimiter.js     # Rate limiting
│   ├── culturalProtocol.js # FPIC compliance
│   └── errorHandler.js    # Error handling
├── routes/
│   ├── species.js         # Species endpoints
│   ├── ecosystems.js      # Ecosystem endpoints
│   ├── observations.js    # Citizen science
│   ├── culturalKnowledge.js # Traditional knowledge
│   ├── conservation.js    # Conservation actions
│   ├── justice.js         # Environmental justice
│   └── web3.js            # Blockchain integration
├── utils/
│   └── logger.js          # Winston logger
└── package.json
```

## API Documentation

Interactive API documentation available at:

**Development**: `http://localhost:3000/api-docs`

**Production**: `https://api.boriken-biodiversity.org/api-docs`

OpenAPI 3.0 spec available at: `/api-docs.json`

## License

MIT License - See LICENSE file

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## Cultural Acknowledgment

This API serves data about Borikén (Puerto Rico), the ancestral home of the Taíno people. All traditional knowledge is protected by Free, Prior, and Informed Consent protocols and governed by Indigenous Data Sovereignty principles.

## Support

- GitHub Issues: https://github.com/your-org/puerto-rico-ecology/issues
- Email: api@boriken-biodiversity.org
- Cultural Guardians: guardians@boriken-biodiversity.org

## Links

- [PostgreSQL Schema](../../schemas/postgresql_schema.sql)
- [GraphQL Schema](../../schemas/graphql_schema.graphql)
- [Main Repository](https://github.com/your-org/puerto-rico-ecology)
- [OpenAPI Documentation](http://localhost:3000/api-docs)
