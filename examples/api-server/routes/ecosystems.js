/**
 * Ecosystems Routes
 */

const express = require('express');
const { query, param, validationResult } = require('express-validator');
const router = express.Router();
const db = require('../config/database');

router.get('/', async (req, res, next) => {
  try {
    const { ecosystem_type, protection_status } = req.query;

    let queryText = `
      SELECT
        id, name, name_spanish, taino_name, ecosystem_type,
        location_name, area_km2, elevation_min_m, elevation_max_m,
        species_count_total, species_count_endemic, species_count_threatened,
        protection_status, cultural_significance, sacred_site
      FROM ecosystems
      WHERE 1=1
    `;

    const params = [];
    let paramCount = 1;

    if (ecosystem_type) {
      queryText += ` AND ecosystem_type = $${paramCount}`;
      params.push(ecosystem_type);
      paramCount++;
    }

    if (protection_status) {
      queryText += ` AND protection_status = $${paramCount}`;
      params.push(protection_status);
      paramCount++;
    }

    queryText += ' ORDER BY species_count_total DESC';

    const result = await db.query(queryText, params);

    res.json({
      data: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    next(error);
  }
});

router.get('/:id', [param('id').isUUID()], async (req, res, next) => {
  try {
    const { id } = req.params;

    const result = await db.query(`
      SELECT e.*,
        (SELECT COUNT(*) FROM species_habitats WHERE ecosystem_id = e.id) AS species_in_ecosystem
      FROM ecosystems e
      WHERE e.id = $1
    `, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Ecosystem not found' });
    }

    res.json({ data: result.rows[0] });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
