/**
 * Cultural Protocol Middleware
 *
 * Adds required cultural acknowledgments and FPIC disclaimers to API responses
 */

const culturalProtocol = (req, res, next) => {
  // Store original json method
  const originalJson = res.json.bind(res);

  // Override json method to add cultural protocol headers and metadata
  res.json = function(data) {
    // Add cultural protocol headers
    res.setHeader('X-Cultural-Protocol', 'FPIC-Required');
    res.setHeader('X-Data-Sovereignty', 'Indigenous-Governance');
    res.setHeader('X-Attribution-Required', 'true');

    // Check if this is a cultural knowledge endpoint
    const isCulturalEndpoint = req.path.includes('/cultural');

    // Add cultural metadata to response
    const enhancedData = {
      ...data,
      _cultural_protocol: {
        acknowledgment: 'This knowledge belongs to the Indigenous peoples of Borikén (Puerto Rico) and their descendants',
        fpic_status: 'Free, Prior, and Informed Consent required for commercial use',
        attribution_required: true,
        data_sovereignty: 'Governed by Indigenous Data Sovereignty principles',
        ...(isCulturalEndpoint && {
          sensitive_content_notice: 'This endpoint contains traditional knowledge protected by cultural protocols',
          usage_restrictions: 'Commercial use requires community consent and benefit sharing',
          contact: process.env.CULTURAL_GUARDIAN_EMAIL || 'guardians@boriken-biodiversity.org'
        })
      }
    };

    return originalJson(enhancedData);
  };

  next();
};

module.exports = culturalProtocol;
