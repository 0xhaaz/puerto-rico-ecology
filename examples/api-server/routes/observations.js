/**
 * Observations Routes - Citizen Science
 */

const express = require('express');
const { body, query, validationResult } = require('express-validator');
const router = express.Router();
const db = require('../config/database');
const { writeLimiter } = require('../middleware/rateLimiter');

router.get('/', async (req, res, next) => {
  try {
    const { days = 30, species_id, verified } = req.query;

    let queryText = `
      SELECT
        o.id, o.observation_date, o.individual_count, o.verified,
        s.common_name, t.scientific_name,
        ST_Y(o.location::geometry) AS latitude,
        ST_X(o.location::geometry) AS longitude
      FROM species_observations o
      JOIN species s ON o.species_id = s.id
      JOIN taxonomy t ON s.taxonomy_id = t.id
      WHERE o.observation_date >= CURRENT_DATE - $1::interval
    `;

    const params = [`${days} days`];
    let paramCount = 2;

    if (species_id) {
      queryText += ` AND o.species_id = $${paramCount}`;
      params.push(species_id);
      paramCount++;
    }

    if (verified !== undefined) {
      queryText += ` AND o.verified = $${paramCount}`;
      params.push(verified === 'true');
      paramCount++;
    }

    queryText += ' ORDER BY o.observation_date DESC LIMIT 100';

    const result = await db.query(queryText, params);

    res.json({
      data: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    next(error);
  }
});

router.post('/', writeLimiter, [
  body('species_id').isUUID(),
  body('latitude').isFloat({ min: -90, max: 90 }),
  body('longitude').isFloat({ min: -180, max: 180 }),
  body('observation_date').isDate(),
  body('observer_name').optional().isString(),
  body('individual_count').optional().isInt({ min: 1 })
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const {
      species_id, latitude, longitude, observation_date,
      observer_name, observer_email, individual_count
    } = req.body;

    const result = await db.query(`
      INSERT INTO species_observations
        (species_id, location, observation_date, observer_name, observer_email, individual_count)
      VALUES
        ($1, ST_SetSRID(ST_MakePoint($2, $3), 4326)::geography, $4, $5, $6, $7)
      RETURNING *
    `, [species_id, longitude, latitude, observation_date, observer_name, observer_email, individual_count]);

    res.status(201).json({
      message: 'Observation submitted successfully',
      data: result.rows[0]
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
