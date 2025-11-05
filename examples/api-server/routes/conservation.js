/**
 * Conservation Routes
 */

const express = require('express');
const router = express.Router();
const db = require('../config/database');

router.get('/actions', async (req, res, next) => {
  try {
    const { action_type, ongoing } = req.query;

    let queryText = `
      SELECT
        id, action_name, action_type, implementing_organization,
        start_date, end_date, ongoing, total_budget_usd,
        effectiveness, community_involvement, indigenous_leadership
      FROM conservation_actions
      WHERE 1=1
    `;

    const params = [];
    let paramCount = 1;

    if (action_type) {
      queryText += ` AND action_type = $${paramCount}`;
      params.push(action_type);
      paramCount++;
    }

    if (ongoing !== undefined) {
      queryText += ` AND ongoing = $${paramCount}`;
      params.push(ongoing === 'true');
      paramCount++;
    }

    queryText += ' ORDER BY start_date DESC';

    const result = await db.query(queryText, params);

    res.json({
      data: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    next(error);
  }
});

router.get('/invasive-species', async (req, res, next) => {
  try {
    const result = await db.query(`
      SELECT
        i.*, s.common_name, t.scientific_name
      FROM invasive_species i
      JOIN species s ON i.species_id = s.id
      JOIN taxonomy t ON s.taxonomy_id = t.id
      ORDER BY i.ecological_impact DESC
    `);

    res.json({
      data: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
