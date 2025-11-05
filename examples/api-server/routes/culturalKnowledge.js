/**
 * Cultural Knowledge Routes - FPIC Protected
 */

const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { culturalKnowledgeLimiter } = require('../middleware/rateLimiter');

// Apply strict rate limiting to all cultural knowledge endpoints
router.use(culturalKnowledgeLimiter);

router.get('/', async (req, res, next) => {
  try {
    // Only return public access cultural knowledge
    const result = await db.query(`
      SELECT
        ck.id, ck.knowledge_type, ck.traditional_use,
        ck.cultural_significance, ck.sensitivity_level,
        s.common_name, t.scientific_name
      FROM cultural_knowledge ck
      JOIN species s ON ck.species_id = s.id
      JOIN taxonomy t ON s.taxonomy_id = t.id
      WHERE ck.public_access = true
        AND ck.sensitivity_level = 'public'
      ORDER BY ck.cultural_significance DESC
    `);

    res.json({
      data: result.rows,
      count: result.rows.length,
      notice: 'Only public cultural knowledge is shown. Sacred and restricted knowledge requires community approval.',
      fpic_compliance: 'This endpoint respects Free, Prior, and Informed Consent protocols'
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
