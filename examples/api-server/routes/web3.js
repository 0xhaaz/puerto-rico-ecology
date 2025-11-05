/**
 * Web3 Routes - NFT, DAO, Tokens
 */

const express = require('express');
const router = express.Router();
const db = require('../config/database');

router.get('/nft-ready-species', async (req, res, next) => {
  try {
    const result = await db.query(`
      SELECT
        s.id, s.common_name, s.taino_name, t.scientific_name,
        s.endemic_status, s.conservation_status,
        s.rarity_score, s.cultural_value, s.ecological_value,
        (SELECT COUNT(*) FROM nft_metadata WHERE species_id = s.id AND minted = true) AS minted_count
      FROM species s
      JOIN taxonomy t ON s.taxonomy_id = t.id
      WHERE s.nft_ready = true
      ORDER BY s.rarity_score DESC
    `);

    res.json({
      data: result.rows,
      count: result.rows.length,
      cultural_protocol: {
        notice: 'All NFTs must include cultural attribution and benefit sharing',
        community_benefit_percentage: '50%',
        restrictions: 'Commercial use requires community consent'
      }
    });
  } catch (error) {
    next(error);
  }
});

router.get('/dao-proposals', async (req, res, next) => {
  try {
    const { status = 'active' } = req.query;

    const result = await db.query(`
      SELECT
        id, proposal_title, proposal_type, description,
        funding_requested_usd, status,
        voting_start, voting_end,
        votes_for, votes_against, votes_abstain
      FROM dao_proposals
      WHERE status = $1
      ORDER BY voting_start DESC
    `, [status]);

    res.json({
      data: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    next(error);
  }
});

router.get('/rewards/:wallet_address', async (req, res, next) => {
  try {
    const { wallet_address } = req.params;

    const result = await db.query(`
      SELECT
        action_type, action_description, token_amount,
        token_symbol, usd_value, verified, created_at
      FROM conservation_rewards
      WHERE user_wallet_address = $1
      ORDER BY created_at DESC
    `, [wallet_address]);

    const totalRewards = result.rows.reduce((sum, r) => sum + parseFloat(r.token_amount || 0), 0);

    res.json({
      wallet_address,
      rewards: result.rows,
      total_tokens_earned: totalRewards,
      count: result.rows.length
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
