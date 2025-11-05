/**
 * Species Routes
 *
 * Endpoints for querying species information, population data, and biodiversity metrics
 */

const express = require('express');
const { body, query, param, validationResult } = require('express-validator');
const router = express.Router();
const db = require('../config/database');
const { authenticatedLimiter } = require('../middleware/rateLimiter');

/**
 * @swagger
 * /species:
 *   get:
 *     summary: Get list of species
 *     tags: [Species]
 *     parameters:
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 50
 *           maximum: 500
 *         description: Number of results to return
 *       - in: query
 *         name: offset
 *         schema:
 *           type: integer
 *           default: 0
 *         description: Number of results to skip
 *       - in: query
 *         name: endemic_status
 *         schema:
 *           type: string
 *           enum: [endemic_puerto_rico, endemic_caribbean, native, introduced, invasive]
 *         description: Filter by endemic status
 *       - in: query
 *         name: conservation_status
 *         schema:
 *           type: string
 *           enum: [critically_endangered, endangered, vulnerable, near_threatened, least_concern]
 *         description: Filter by conservation status
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Search by common name or scientific name
 *       - in: query
 *         name: nft_ready
 *         schema:
 *           type: boolean
 *         description: Filter NFT-ready species
 *     responses:
 *       200:
 *         description: List of species
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                 pagination:
 *                   type: object
 *                 count:
 *                   type: integer
 */
router.get('/', [
  query('limit').optional().isInt({ min: 1, max: 500 }).toInt(),
  query('offset').optional().isInt({ min: 0 }).toInt(),
  query('endemic_status').optional().isString(),
  query('conservation_status').optional().isString(),
  query('search').optional().isString(),
  query('nft_ready').optional().isBoolean()
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const {
      limit = 50,
      offset = 0,
      endemic_status,
      conservation_status,
      search,
      nft_ready
    } = req.query;

    // Build query
    let queryText = `
      SELECT
        s.id,
        s.common_name,
        s.common_name_spanish,
        s.taino_name,
        t.scientific_name,
        t.kingdom,
        t.class,
        t."order",
        t.family,
        s.endemic_status,
        s.conservation_status,
        s.population_estimate_min,
        s.population_estimate_max,
        s.population_trend,
        s.description,
        s.cultural_value,
        s.ecological_value,
        s.rarity_score,
        s.nft_ready,
        s.updated_at
      FROM species s
      JOIN taxonomy t ON s.taxonomy_id = t.id
      WHERE 1=1
    `;

    const params = [];
    let paramCount = 1;

    if (endemic_status) {
      queryText += ` AND s.endemic_status = $${paramCount}`;
      params.push(endemic_status);
      paramCount++;
    }

    if (conservation_status) {
      queryText += ` AND s.conservation_status = $${paramCount}`;
      params.push(conservation_status);
      paramCount++;
    }

    if (search) {
      queryText += ` AND (
        s.common_name ILIKE $${paramCount} OR
        s.common_name_spanish ILIKE $${paramCount} OR
        s.taino_name ILIKE $${paramCount} OR
        t.scientific_name ILIKE $${paramCount}
      )`;
      params.push(`%${search}%`);
      paramCount++;
    }

    if (nft_ready !== undefined) {
      queryText += ` AND s.nft_ready = $${paramCount}`;
      params.push(nft_ready);
      paramCount++;
    }

    // Get total count
    const countQuery = `SELECT COUNT(*) FROM (${queryText}) AS count_query`;
    const countResult = await db.query(countQuery, params);
    const totalCount = parseInt(countResult.rows[0].count);

    // Add pagination
    queryText += ` ORDER BY s.rarity_score DESC NULLS LAST, s.common_name
      LIMIT $${paramCount} OFFSET $${paramCount + 1}`;
    params.push(limit, offset);

    const result = await db.query(queryText, params);

    res.json({
      data: result.rows,
      pagination: {
        limit,
        offset,
        total: totalCount,
        hasMore: offset + limit < totalCount
      },
      count: result.rows.length
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /species/{id}:
 *   get:
 *     summary: Get species by ID
 *     tags: [Species]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Species details
 *       404:
 *         description: Species not found
 */
router.get('/:id', [
  param('id').isUUID()
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { id } = req.params;

    const result = await db.query(`
      SELECT
        s.*,
        t.scientific_name,
        t.kingdom,
        t.phylum,
        t.class,
        t."order",
        t.family,
        t.genus,
        t.species,
        t.authority,
        (
          SELECT json_agg(json_build_object(
            'year', year,
            'population_estimate', population_estimate,
            'wild_population', wild_population,
            'captive_population', captive_population
          ) ORDER BY year)
          FROM population_history
          WHERE species_id = s.id
        ) AS population_history
      FROM species s
      JOIN taxonomy t ON s.taxonomy_id = t.id
      WHERE s.id = $1
    `, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Species not found',
        message: `No species found with ID: ${id}`
      });
    }

    res.json({
      data: result.rows[0]
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /species/endemic/list:
 *   get:
 *     summary: Get all endemic species
 *     tags: [Species]
 *     responses:
 *       200:
 *         description: List of endemic species
 */
router.get('/endemic/list', async (req, res, next) => {
  try {
    const result = await db.query(`
      SELECT
        s.id,
        s.common_name,
        s.taino_name,
        t.scientific_name,
        s.conservation_status,
        s.endemic_status,
        s.cultural_value,
        s.rarity_score
      FROM species s
      JOIN taxonomy t ON s.taxonomy_id = t.id
      WHERE s.endemic_status IN ('endemic_puerto_rico', 'endemic_caribbean')
      ORDER BY s.rarity_score DESC
    `);

    res.json({
      data: result.rows,
      count: result.rows.length,
      metadata: {
        description: 'Endemic species are found nowhere else on Earth',
        puerto_rico_endemics: result.rows.filter(r => r.endemic_status === 'endemic_puerto_rico').length,
        caribbean_endemics: result.rows.filter(r => r.endemic_status === 'endemic_caribbean').length
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /species/endangered/list:
 *   get:
 *     summary: Get all endangered and critically endangered species
 *     tags: [Species]
 *     responses:
 *       200:
 *         description: List of endangered species with habitat information
 */
router.get('/endangered/list', async (req, res, next) => {
  try {
    const result = await db.query(`
      SELECT
        s.id,
        s.common_name,
        t.scientific_name,
        s.conservation_status,
        s.population_estimate_min,
        s.population_estimate_max,
        s.population_trend,
        json_agg(DISTINCT jsonb_build_object(
          'ecosystem_name', e.name,
          'ecosystem_type', e.ecosystem_type,
          'protection_status', e.protection_status
        )) FILTER (WHERE e.id IS NOT NULL) AS habitats,
        json_agg(DISTINCT jsonb_build_object(
          'threat_name', th.threat_name,
          'severity', st.severity
        )) FILTER (WHERE th.id IS NOT NULL) AS threats
      FROM species s
      JOIN taxonomy t ON s.taxonomy_id = t.id
      LEFT JOIN species_habitats sh ON s.id = sh.species_id
      LEFT JOIN ecosystems e ON sh.ecosystem_id = e.id
      LEFT JOIN species_threats st ON s.id = st.species_id
      LEFT JOIN threats th ON st.threat_id = th.id
      WHERE s.conservation_status IN ('critically_endangered', 'endangered')
      GROUP BY s.id, t.scientific_name
      ORDER BY
        CASE s.conservation_status
          WHEN 'critically_endangered' THEN 1
          WHEN 'endangered' THEN 2
        END,
        s.common_name
    `);

    res.json({
      data: result.rows,
      count: result.rows.length,
      urgency: {
        critically_endangered: result.rows.filter(r => r.conservation_status === 'critically_endangered').length,
        endangered: result.rows.filter(r => r.conservation_status === 'endangered').length
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /species/search/near:
 *   get:
 *     summary: Find species near a location
 *     tags: [Species]
 *     parameters:
 *       - in: query
 *         name: latitude
 *         required: true
 *         schema:
 *           type: number
 *       - in: query
 *         name: longitude
 *         required: true
 *         schema:
 *           type: number
 *       - in: query
 *         name: radius_km
 *         required: true
 *         schema:
 *           type: number
 *           maximum: 50
 *     responses:
 *       200:
 *         description: Species found near location
 */
router.get('/search/near', [
  query('latitude').isFloat({ min: -90, max: 90 }).toFloat(),
  query('longitude').isFloat({ min: -180, max: 180 }).toFloat(),
  query('radius_km').isFloat({ min: 0.1, max: 50 }).toFloat()
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { latitude, longitude, radius_km } = req.query;

    const result = await db.query(`
      SELECT * FROM species_near_location($1, $2, $3)
    `, [latitude, longitude, radius_km]);

    res.json({
      data: result.rows,
      count: result.rows.length,
      search_parameters: {
        center: { latitude, longitude },
        radius_km
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /species/{id}/population-trend:
 *   get:
 *     summary: Get population trend for a species
 *     tags: [Species]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Population trend data
 */
router.get('/:id/population-trend', [
  param('id').isUUID()
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { id } = req.params;

    // Get species info
    const speciesResult = await db.query(`
      SELECT s.common_name, t.scientific_name
      FROM species s
      JOIN taxonomy t ON s.taxonomy_id = t.id
      WHERE s.id = $1
    `, [id]);

    if (speciesResult.rows.length === 0) {
      return res.status(404).json({
        error: 'Species not found',
        message: `No species found with ID: ${id}`
      });
    }

    // Get population trend
    const trendResult = await db.query(`
      SELECT * FROM get_population_trend($1)
    `, [id]);

    res.json({
      species: speciesResult.rows[0],
      trend_data: trendResult.rows,
      analysis: {
        years_tracked: trendResult.rows.length,
        earliest_year: trendResult.rows[0]?.year,
        latest_year: trendResult.rows[trendResult.rows.length - 1]?.year,
        overall_change: trendResult.rows.length > 1
          ? ((trendResult.rows[trendResult.rows.length - 1].population - trendResult.rows[0].population)
            / trendResult.rows[0].population * 100).toFixed(2) + '%'
          : null
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /species/stats:
 *   get:
 *     summary: Get biodiversity statistics
 *     tags: [Species]
 *     responses:
 *       200:
 *         description: Comprehensive biodiversity stats
 */
router.get('/stats/biodiversity', async (req, res, next) => {
  try {
    const result = await db.query(`
      SELECT
        COUNT(*) AS total_species,
        COUNT(*) FILTER (WHERE endemic_status IN ('endemic_puerto_rico', 'endemic_caribbean')) AS endemic_species,
        COUNT(*) FILTER (WHERE conservation_status = 'critically_endangered') AS critically_endangered,
        COUNT(*) FILTER (WHERE conservation_status = 'endangered') AS endangered,
        COUNT(*) FILTER (WHERE conservation_status = 'vulnerable') AS vulnerable,
        COUNT(*) FILTER (WHERE nft_ready = true) AS nft_ready_species,
        AVG(rarity_score) FILTER (WHERE rarity_score IS NOT NULL) AS avg_rarity_score,
        AVG(cultural_value) FILTER (WHERE cultural_value IS NOT NULL) AS avg_cultural_value
      FROM species
    `);

    const taxonomyResult = await db.query(`
      SELECT
        t.kingdom,
        t.class,
        COUNT(*) AS species_count
      FROM species s
      JOIN taxonomy t ON s.taxonomy_id = t.id
      GROUP BY t.kingdom, t.class
      ORDER BY COUNT(*) DESC
    `);

    res.json({
      overall_stats: result.rows[0],
      taxonomy_breakdown: taxonomyResult.rows,
      metadata: {
        last_updated: new Date().toISOString(),
        data_quality: 'verified',
        source: 'Borikén Biodiversity Database'
      }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
