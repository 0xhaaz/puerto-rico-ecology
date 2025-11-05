/**
 * Environmental Justice Routes
 */

const express = require('express');
const router = express.Router();
const db = require('../config/database');

router.get('/sacrifice-zones', async (req, res, next) => {
  try {
    const result = await db.query(`
      SELECT
        community_name, community_name_spanish, municipality,
        population, poverty_rate, percent_minority,
        pollution_sources, superfund_sites, coal_ash_exposure,
        flood_risk, maria_damage_level, days_without_power_post_maria,
        community_organizing_active, organizing_groups,
        ST_Y(location::geometry) AS latitude,
        ST_X(location::geometry) AS longitude
      FROM environmental_justice_communities
      WHERE sacrifice_zone = true
      ORDER BY poverty_rate DESC
    `);

    res.json({
      data: result.rows,
      count: result.rows.length,
      context: {
        description: 'Sacrifice zones are communities bearing disproportionate environmental burdens',
        source: 'Based on pollution exposure, demographics, and Hurricane Maria recovery data'
      }
    });
  } catch (error) {
    next(error);
  }
});

router.get('/food-systems', async (req, res, next) => {
  try {
    const { municipality } = req.query;

    let queryText = `
      SELECT *
      FROM food_systems
      WHERE 1=1
    `;

    const params = [];
    if (municipality) {
      queryText += ' AND municipality = $1';
      params.push(municipality);
    }

    const result = await db.query(queryText, params);

    res.json({
      data: result.rows,
      count: result.rows.length,
      context: {
        island_import_dependence: '85%',
        food_sovereignty_goal: 'Rebuild local agricultural systems'
      }
    });
  } catch (error) {
    next(error);
  }
});

router.get('/economic-ecology', async (req, res, next) => {
  try {
    const result = await db.query(`
      SELECT *
      FROM economic_ecology
      ORDER BY measurement_year DESC, value_usd DESC
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
