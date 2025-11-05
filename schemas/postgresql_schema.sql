-- =====================================================
-- Borikén Biodiversity Database - PostgreSQL Schema
-- =====================================================
-- Version: 1.0.0
-- Last Updated: 2025-11-05
-- Description: Comprehensive database schema for Puerto Rico's biodiversity
--              with spatial support, cultural protocols, and justice framework
-- Requirements: PostgreSQL 14+, PostGIS 3.0+
-- =====================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS pg_trgm;  -- For fuzzy text search
CREATE EXTENSION IF NOT EXISTS btree_gist;  -- For time-series indexing
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";  -- For UUID generation

-- =====================================================
-- 1. TAXONOMY & SPECIES
-- =====================================================

-- Main taxonomy hierarchy
CREATE TABLE taxonomy (
    id SERIAL PRIMARY KEY,
    kingdom VARCHAR(50) NOT NULL,
    phylum VARCHAR(50),
    class VARCHAR(50),
    "order" VARCHAR(50),
    family VARCHAR(50),
    genus VARCHAR(50),
    species VARCHAR(100),
    subspecies VARCHAR(100),
    scientific_name VARCHAR(200) UNIQUE NOT NULL,
    authority VARCHAR(200),  -- Original descriptor
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT scientific_name_format CHECK (scientific_name ~ '^[A-Z][a-z]+ [a-z]+.*$')
);

-- Species master table
CREATE TABLE species (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    taxonomy_id INTEGER REFERENCES taxonomy(id) ON DELETE CASCADE,
    common_name VARCHAR(200),
    common_name_spanish VARCHAR(200),
    taino_name VARCHAR(200),
    taino_etymology TEXT,

    -- Endemic status
    endemic_status VARCHAR(50) CHECK (endemic_status IN (
        'endemic_puerto_rico',
        'endemic_caribbean',
        'native',
        'introduced',
        'invasive',
        'vagrant'
    )),

    -- Conservation status (IUCN)
    conservation_status VARCHAR(50) CHECK (conservation_status IN (
        'extinct',
        'extinct_in_wild',
        'critically_endangered',
        'endangered',
        'vulnerable',
        'near_threatened',
        'least_concern',
        'data_deficient',
        'not_evaluated'
    )),
    conservation_status_date DATE,

    -- Description
    description TEXT,
    physical_description TEXT,
    behavior TEXT,
    diet TEXT,
    reproduction TEXT,
    lifespan_years_min NUMERIC(5,2),
    lifespan_years_max NUMERIC(5,2),

    -- Size metrics
    size_length_cm_min NUMERIC(8,2),
    size_length_cm_max NUMERIC(8,2),
    size_wingspan_cm_min NUMERIC(8,2),
    size_wingspan_cm_max NUMERIC(8,2),
    size_weight_g_min NUMERIC(10,2),
    size_weight_g_max NUMERIC(10,2),

    -- Current status
    population_estimate_min INTEGER,
    population_estimate_max INTEGER,
    population_estimate_year INTEGER,
    population_trend VARCHAR(20) CHECK (population_trend IN (
        'increasing',
        'stable',
        'decreasing',
        'unknown',
        'extinct'
    )),

    -- References
    primary_reference TEXT,
    iucn_link TEXT,
    gbif_id VARCHAR(50),

    -- Web3 metadata
    nft_ready BOOLEAN DEFAULT false,
    rarity_score NUMERIC(5,2),  -- 0-100 scale
    cultural_value NUMERIC(5,2),  -- 0-100 scale
    ecological_value NUMERIC(5,2),  -- 0-100 scale

    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    data_quality VARCHAR(20) DEFAULT 'verified' CHECK (data_quality IN (
        'verified',
        'preliminary',
        'unverified',
        'disputed'
    ))
);

-- Species common names (for multiple common names)
CREATE TABLE species_common_names (
    id SERIAL PRIMARY KEY,
    species_id UUID REFERENCES species(id) ON DELETE CASCADE,
    common_name VARCHAR(200) NOT NULL,
    language VARCHAR(10) NOT NULL,  -- 'en', 'es', 'taino'
    is_primary BOOLEAN DEFAULT false,
    region VARCHAR(100),  -- Where this name is used
    created_at TIMESTAMP DEFAULT NOW()
);

-- Population time-series data
CREATE TABLE population_history (
    id SERIAL PRIMARY KEY,
    species_id UUID REFERENCES species(id) ON DELETE CASCADE,
    year INTEGER NOT NULL,
    population_estimate INTEGER,
    population_min INTEGER,
    population_max INTEGER,
    wild_population INTEGER,
    captive_population INTEGER,
    methodology TEXT,
    data_source TEXT,
    confidence_level VARCHAR(20) CHECK (confidence_level IN (
        'high',
        'medium',
        'low',
        'estimated'
    )),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(species_id, year)
);

-- =====================================================
-- 2. HABITATS & ECOSYSTEMS
-- =====================================================

-- Ecosystem types
CREATE TABLE ecosystems (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    name_spanish VARCHAR(200),
    taino_name VARCHAR(200),
    ecosystem_type VARCHAR(50) CHECK (ecosystem_type IN (
        'tropical_rainforest',
        'subtropical_dry_forest',
        'subtropical_moist_forest',
        'mangrove',
        'coral_reef',
        'seagrass_meadow',
        'cave_system',
        'cloud_forest',
        'coastal_scrub',
        'wetland',
        'freshwater_stream',
        'lagoon',
        'agricultural',
        'urban'
    )),

    -- Geographic data
    location_name VARCHAR(200),
    geography GEOGRAPHY(POLYGON, 4326),  -- PostGIS geography for lat/lon
    area_km2 NUMERIC(10,2),
    elevation_min_m INTEGER,
    elevation_max_m INTEGER,

    -- Climate data
    annual_rainfall_mm_min INTEGER,
    annual_rainfall_mm_max INTEGER,
    temperature_avg_c NUMERIC(4,1),

    -- Biodiversity metrics
    species_count_total INTEGER,
    species_count_endemic INTEGER,
    species_count_threatened INTEGER,

    -- Description
    description TEXT,
    ecological_importance TEXT,
    threats TEXT[],  -- Array of threat types

    -- Conservation
    protection_status VARCHAR(50) CHECK (protection_status IN (
        'national_forest',
        'national_wildlife_refuge',
        'state_forest',
        'unesco_biosphere_reserve',
        'marine_protected_area',
        'critical_habitat',
        'private_conservation',
        'unprotected'
    )),
    protection_level VARCHAR(20),
    managing_agency VARCHAR(200),

    -- Cultural significance
    cultural_significance VARCHAR(20) CHECK (cultural_significance IN (
        'very_high',
        'high',
        'moderate',
        'low'
    )),
    sacred_site BOOLEAN DEFAULT false,
    spiritual_significance TEXT,

    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Species-habitat relationships
CREATE TABLE species_habitats (
    id SERIAL PRIMARY KEY,
    species_id UUID REFERENCES species(id) ON DELETE CASCADE,
    ecosystem_id UUID REFERENCES ecosystems(id) ON DELETE CASCADE,
    habitat_preference VARCHAR(20) CHECK (habitat_preference IN (
        'primary',
        'secondary',
        'occasional',
        'rare'
    )),
    breeding_habitat BOOLEAN DEFAULT false,
    feeding_habitat BOOLEAN DEFAULT false,
    seasonal BOOLEAN DEFAULT false,
    season VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(species_id, ecosystem_id)
);

-- Geographic distribution points
CREATE TABLE species_observations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    species_id UUID REFERENCES species(id) ON DELETE CASCADE,
    location GEOGRAPHY(POINT, 4326),
    observation_date DATE NOT NULL,
    observation_time TIME,
    observer_name VARCHAR(200),
    observer_email VARCHAR(200),

    -- Observation details
    individual_count INTEGER,
    life_stage VARCHAR(50) CHECK (life_stage IN (
        'adult',
        'juvenile',
        'larva',
        'egg',
        'seedling',
        'unknown'
    )),
    sex VARCHAR(20) CHECK (sex IN ('male', 'female', 'unknown')),
    behavior_observed TEXT,

    -- Verification
    verified BOOLEAN DEFAULT false,
    verified_by VARCHAR(200),
    verified_date DATE,

    -- Media
    has_photo BOOLEAN DEFAULT false,
    has_audio BOOLEAN DEFAULT false,
    media_urls TEXT[],

    -- Citizen science
    project_name VARCHAR(200),
    observation_platform VARCHAR(100),  -- iNaturalist, eBird, etc.
    external_id VARCHAR(100),

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 3. CULTURAL KNOWLEDGE & TRADITIONAL USE
-- =====================================================

-- Cultural knowledge database with FPIC protocols
CREATE TABLE cultural_knowledge (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    species_id UUID REFERENCES species(id) ON DELETE CASCADE,

    -- Knowledge content
    knowledge_type VARCHAR(50) CHECK (knowledge_type IN (
        'medicinal',
        'ceremonial',
        'food',
        'craft',
        'spiritual',
        'ecological',
        'astronomical',
        'seasonal',
        'navigation',
        'symbolic'
    )),
    traditional_use TEXT NOT NULL,
    preparation_method TEXT,
    seasonal_timing TEXT,
    spiritual_context TEXT,
    taboos_restrictions TEXT,

    -- Attribution & sovereignty
    knowledge_holder VARCHAR(200),
    community_source VARCHAR(200),
    elder_name VARCHAR(200),  -- With consent
    documentation_date DATE,

    -- Cultural protocols (FPIC compliance)
    sensitivity_level VARCHAR(20) NOT NULL CHECK (sensitivity_level IN (
        'public',
        'community_only',
        'sacred',
        'restricted'
    )),
    fpic_status VARCHAR(50) CHECK (fpic_status IN (
        'consent_granted',
        'consent_pending',
        'consent_denied',
        'not_required'
    )),
    fpic_documentation TEXT,
    community_approval_status VARCHAR(50),
    elder_consultation_complete BOOLEAN DEFAULT false,

    -- Access control
    public_access BOOLEAN DEFAULT false,
    commercial_use_allowed BOOLEAN DEFAULT false,
    attribution_required BOOLEAN DEFAULT true,
    benefit_sharing_agreement TEXT,

    -- Usage restrictions
    usage_restrictions TEXT NOT NULL,
    prohibited_uses TEXT[],
    required_protocols TEXT[],

    -- Metadata
    cultural_significance VARCHAR(20) CHECK (cultural_significance IN (
        'very_high',
        'high',
        'moderate',
        'low'
    )),
    historical_continuity BOOLEAN,  -- Still practiced today?
    endangerment_status VARCHAR(50),  -- Is this knowledge at risk?

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Traditional ecological calendar
CREATE TABLE ecological_calendar (
    id SERIAL PRIMARY KEY,
    event_name VARCHAR(200) NOT NULL,
    event_name_taino VARCHAR(200),
    event_type VARCHAR(50) CHECK (event_type IN (
        'migration',
        'breeding',
        'flowering',
        'fruiting',
        'harvesting',
        'ceremony',
        'seasonal_change'
    )),

    -- Timing
    start_month INTEGER CHECK (start_month BETWEEN 1 AND 12),
    end_month INTEGER CHECK (end_month BETWEEN 1 AND 12),
    lunar_phase VARCHAR(50),

    -- Related species
    primary_species_id UUID REFERENCES species(id),
    related_species UUID[],  -- Array of species UUIDs

    -- Traditional knowledge
    traditional_significance TEXT,
    contemporary_relevance TEXT,

    created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 4. CONSERVATION & THREATS
-- =====================================================

-- Threat categories
CREATE TABLE threats (
    id SERIAL PRIMARY KEY,
    threat_name VARCHAR(200) NOT NULL UNIQUE,
    threat_category VARCHAR(50) CHECK (threat_category IN (
        'habitat_loss',
        'habitat_degradation',
        'invasive_species',
        'climate_change',
        'pollution',
        'overharvesting',
        'disease',
        'predation',
        'human_disturbance',
        'natural_disasters',
        'genetic_factors'
    )),
    description TEXT,
    mitigation_strategies TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Species-specific threats
CREATE TABLE species_threats (
    id SERIAL PRIMARY KEY,
    species_id UUID REFERENCES species(id) ON DELETE CASCADE,
    threat_id INTEGER REFERENCES threats(id),
    severity VARCHAR(20) CHECK (severity IN (
        'critical',
        'high',
        'moderate',
        'low',
        'unknown'
    )),
    trend VARCHAR(20) CHECK (trend IN (
        'increasing',
        'stable',
        'decreasing',
        'unknown'
    )),
    specific_details TEXT,
    geographic_scope VARCHAR(100),
    first_documented DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Conservation actions
CREATE TABLE conservation_actions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    action_name VARCHAR(200) NOT NULL,
    action_type VARCHAR(50) CHECK (action_type IN (
        'habitat_protection',
        'habitat_restoration',
        'species_recovery',
        'captive_breeding',
        'reintroduction',
        'invasive_control',
        'research',
        'monitoring',
        'education',
        'policy',
        'community_based',
        'traditional_practices'
    )),

    -- Scope
    target_species UUID[] NOT NULL,  -- Array of species UUIDs
    target_ecosystems UUID[],  -- Array of ecosystem UUIDs
    geographic_area GEOGRAPHY(POLYGON, 4326),

    -- Implementation
    implementing_organization VARCHAR(200),
    partner_organizations TEXT[],
    community_involvement BOOLEAN DEFAULT false,
    indigenous_leadership BOOLEAN DEFAULT false,

    -- Timeline
    start_date DATE,
    end_date DATE,
    ongoing BOOLEAN DEFAULT true,

    -- Funding
    total_budget_usd NUMERIC(12,2),
    funding_sources TEXT[],

    -- Results
    success_metrics TEXT,
    results_summary TEXT,
    effectiveness VARCHAR(20) CHECK (effectiveness IN (
        'highly_effective',
        'moderately_effective',
        'limited_effectiveness',
        'ineffective',
        'too_early_to_assess'
    )),

    -- References
    project_url TEXT,
    reports TEXT[],

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Invasive species tracking
CREATE TABLE invasive_species (
    id SERIAL PRIMARY KEY,
    species_id UUID REFERENCES species(id) ON DELETE CASCADE,
    origin_region VARCHAR(200),
    introduction_date_min INTEGER,
    introduction_date_max INTEGER,
    introduction_pathway VARCHAR(100),

    -- Impact assessment
    ecological_impact VARCHAR(20) CHECK (ecological_impact IN (
        'severe',
        'high',
        'moderate',
        'low',
        'unknown'
    )),
    economic_impact_usd NUMERIC(15,2),
    human_health_impact BOOLEAN DEFAULT false,

    -- Distribution
    current_distribution_area_km2 NUMERIC(10,2),
    spread_rate VARCHAR(20) CHECK (spread_rate IN (
        'rapid',
        'moderate',
        'slow',
        'stable'
    )),

    -- Native species affected
    native_species_affected UUID[],
    ecosystems_affected UUID[],

    -- Control efforts
    control_methods TEXT[],
    control_effectiveness VARCHAR(50),
    eradication_feasible BOOLEAN,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 5. JUSTICE FRAMEWORK
-- =====================================================

-- Environmental justice communities
CREATE TABLE environmental_justice_communities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    community_name VARCHAR(200) NOT NULL,
    community_name_spanish VARCHAR(200),
    municipality VARCHAR(100),

    -- Geographic
    location GEOGRAPHY(POINT, 4326),
    boundary GEOGRAPHY(POLYGON, 4326),

    -- Demographics (2020 Census + current estimates)
    population INTEGER,
    median_income_usd INTEGER,
    poverty_rate NUMERIC(5,2),
    unemployment_rate NUMERIC(5,2),
    percent_minority NUMERIC(5,2),
    percent_black NUMERIC(5,2),
    percent_indigenous NUMERIC(5,2),

    -- Environmental burdens
    pollution_sources TEXT[],
    superfund_sites BOOLEAN DEFAULT false,
    coal_ash_exposure BOOLEAN DEFAULT false,
    landfill_proximity_km NUMERIC(5,2),
    industrial_facility_count INTEGER,

    -- Health impacts
    asthma_rate NUMERIC(5,2),
    cancer_cluster BOOLEAN DEFAULT false,
    environmental_health_issues TEXT[],

    -- Climate vulnerability
    flood_risk VARCHAR(20) CHECK (flood_risk IN (
        'extreme',
        'high',
        'moderate',
        'low'
    )),
    hurricane_vulnerability VARCHAR(20),
    heat_island_effect BOOLEAN DEFAULT false,
    sea_level_rise_risk BOOLEAN DEFAULT false,

    -- Infrastructure
    water_quality_issues BOOLEAN DEFAULT false,
    power_grid_reliability VARCHAR(20),
    average_power_outage_hours_yearly INTEGER,

    -- Hurricane Maria impact
    maria_damage_level VARCHAR(20) CHECK (maria_damage_level IN (
        'catastrophic',
        'severe',
        'significant',
        'moderate',
        'minor'
    )),
    maria_recovery_status VARCHAR(50),
    days_without_power_post_maria INTEGER,

    -- Classification
    sacrifice_zone BOOLEAN DEFAULT false,
    environmental_justice_priority BOOLEAN DEFAULT false,

    -- Resistance & resilience
    community_organizing_active BOOLEAN DEFAULT false,
    organizing_groups TEXT[],
    renewable_energy_projects TEXT[],
    community_resilience_initiatives TEXT[],

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Food sovereignty data
CREATE TABLE food_systems (
    id SERIAL PRIMARY KEY,
    municipality VARCHAR(100) NOT NULL,

    -- Agricultural land
    agricultural_land_acres INTEGER,
    actively_farmed_acres INTEGER,
    abandoned_farmland_acres INTEGER,

    -- Food production
    local_food_production_percentage NUMERIC(5,2),
    import_dependence_percentage NUMERIC(5,2),

    -- Traditional agriculture
    conuco_systems_active INTEGER,
    agroecological_farms INTEGER,
    traditional_crops TEXT[],

    -- Food access
    food_desert BOOLEAN DEFAULT false,
    supermarket_access_km NUMERIC(5,2),
    farmers_markets_count INTEGER,

    -- Food security metrics
    food_insecurity_rate NUMERIC(5,2),
    snap_participation_rate NUMERIC(5,2),

    -- Projects
    food_sovereignty_initiatives TEXT[],
    urban_agriculture_projects INTEGER,
    community_gardens INTEGER,
    seed_saving_networks BOOLEAN DEFAULT false,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Economic ecology data
CREATE TABLE economic_ecology (
    id SERIAL PRIMARY KEY,
    metric_name VARCHAR(200) NOT NULL,
    metric_category VARCHAR(50) CHECK (metric_category IN (
        'ecosystem_services',
        'biodiversity_value',
        'tourism_revenue',
        'tax_incentives',
        'conservation_funding',
        'inequality',
        'employment'
    )),

    -- Value metrics
    value_usd NUMERIC(15,2),
    value_per_capita_usd NUMERIC(10,2),
    measurement_year INTEGER,

    -- Beneficiary analysis
    primary_beneficiaries TEXT,
    community_benefit_percentage NUMERIC(5,2),
    corporate_benefit_percentage NUMERIC(5,2),

    -- Geographic scope
    municipality VARCHAR(100),
    ecosystem_id UUID REFERENCES ecosystems(id),

    description TEXT,
    data_source TEXT,

    created_at TIMESTAMP DEFAULT NOW()
);

-- Rights of Nature legal framework
CREATE TABLE rights_of_nature_proposals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proposal_name VARCHAR(200) NOT NULL,
    ecosystem_id UUID REFERENCES ecosystems(id),

    -- Legal framework
    proposed_rights TEXT[] NOT NULL,
    legal_personhood BOOLEAN DEFAULT false,
    guardian_entity VARCHAR(200),

    -- Status
    status VARCHAR(50) CHECK (status IN (
        'proposed',
        'under_consideration',
        'adopted',
        'rejected',
        'implemented'
    )),
    proposal_date DATE,
    adoption_date DATE,

    -- Support
    supporting_organizations TEXT[],
    indigenous_endorsement BOOLEAN DEFAULT false,
    community_support_level VARCHAR(20),

    -- Implementation
    enforcement_mechanisms TEXT,
    monitoring_protocols TEXT,

    description TEXT,
    full_text_url TEXT,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 6. WEB3 & BLOCKCHAIN INTEGRATION
-- =====================================================

-- NFT metadata for species
CREATE TABLE nft_metadata (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    species_id UUID REFERENCES species(id) ON DELETE CASCADE,

    -- NFT details
    token_standard VARCHAR(20) CHECK (token_standard IN ('ERC-721', 'ERC-1155')),
    contract_address VARCHAR(42),
    token_id VARCHAR(78),
    blockchain VARCHAR(50) DEFAULT 'Base',

    -- Metadata
    name VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    image_url TEXT,
    external_url TEXT,
    animation_url TEXT,

    -- Attributes (stored as JSONB for flexibility)
    attributes JSONB NOT NULL,

    -- Cultural protocol
    cultural_attribution TEXT NOT NULL,
    usage_restrictions TEXT NOT NULL,
    community_benefit_percentage NUMERIC(5,2) DEFAULT 50.00,
    royalty_recipients TEXT[],

    -- Values
    rarity_score NUMERIC(5,2),
    cultural_significance_score NUMERIC(5,2),
    conservation_priority_score NUMERIC(5,2),

    -- Minting status
    minted BOOLEAN DEFAULT false,
    mint_date TIMESTAMP,
    owner_address VARCHAR(42),

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Conservation token rewards
CREATE TABLE conservation_rewards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_wallet_address VARCHAR(42) NOT NULL,

    -- Action
    action_type VARCHAR(50) CHECK (action_type IN (
        'observation_submitted',
        'species_identified',
        'habitat_restored',
        'invasive_removed',
        'data_verified',
        'education_completed',
        'community_event',
        'traditional_knowledge_shared'
    )),
    action_description TEXT,

    -- Related entities
    species_id UUID REFERENCES species(id),
    ecosystem_id UUID REFERENCES ecosystems(id),
    observation_id UUID REFERENCES species_observations(id),

    -- Reward
    token_amount NUMERIC(18,8),
    token_symbol VARCHAR(10) DEFAULT 'BIODIV',
    usd_value NUMERIC(12,2),

    -- Verification
    verified BOOLEAN DEFAULT false,
    verified_by VARCHAR(200),
    verification_date TIMESTAMP,

    -- Blockchain transaction
    transaction_hash VARCHAR(66),
    block_number INTEGER,

    created_at TIMESTAMP DEFAULT NOW()
);

-- DAO governance proposals
CREATE TABLE dao_proposals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proposal_title VARCHAR(200) NOT NULL,
    proposal_type VARCHAR(50) CHECK (proposal_type IN (
        'conservation_funding',
        'research_grant',
        'community_project',
        'policy_advocacy',
        'protocol_change',
        'emergency_action'
    )),

    -- Proposal details
    description TEXT NOT NULL,
    funding_requested_usd NUMERIC(12,2),
    target_species UUID[],
    target_ecosystems UUID[],
    beneficiary_communities TEXT[],

    -- Voting
    voting_start TIMESTAMP NOT NULL,
    voting_end TIMESTAMP NOT NULL,
    quorum_required NUMERIC(5,2),
    votes_for INTEGER DEFAULT 0,
    votes_against INTEGER DEFAULT 0,
    votes_abstain INTEGER DEFAULT 0,

    -- Status
    status VARCHAR(50) CHECK (status IN (
        'draft',
        'active',
        'passed',
        'rejected',
        'executed',
        'cancelled'
    )),

    -- Execution
    execution_date TIMESTAMP,
    transaction_hash VARCHAR(66),

    -- Proposer
    proposer_address VARCHAR(42) NOT NULL,
    proposer_name VARCHAR(200),

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 7. RESEARCH & EDUCATION
-- =====================================================

-- Research projects
CREATE TABLE research_projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_name VARCHAR(200) NOT NULL,
    project_type VARCHAR(50) CHECK (project_type IN (
        'ecological_study',
        'conservation_biology',
        'taxonomy',
        'ethnobotany',
        'climate_research',
        'restoration_ecology',
        'citizen_science'
    )),

    -- Scope
    target_species UUID[],
    target_ecosystems UUID[],

    -- Organizations
    lead_institution VARCHAR(200),
    collaborating_institutions TEXT[],
    principal_investigator VARCHAR(200),

    -- Timeline
    start_date DATE,
    end_date DATE,

    -- Funding
    funding_amount_usd NUMERIC(12,2),
    funding_sources TEXT[],

    -- Output
    publications TEXT[],
    datasets TEXT[],
    project_url TEXT,

    -- Status
    status VARCHAR(50) CHECK (status IN (
        'planning',
        'active',
        'completed',
        'suspended',
        'cancelled'
    )),

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Educational resources
CREATE TABLE educational_resources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    resource_type VARCHAR(50) CHECK (resource_type IN (
        'lesson_plan',
        'field_guide',
        'video',
        'interactive_tool',
        'game',
        'infographic',
        'curriculum',
        'workshop'
    )),

    -- Target audience
    audience VARCHAR(50) CHECK (audience IN (
        'children',
        'students',
        'teachers',
        'researchers',
        'community',
        'developers',
        'policymakers'
    )),
    grade_level VARCHAR(50),

    -- Content
    description TEXT,
    learning_objectives TEXT[],
    topics TEXT[],

    -- Related content
    related_species UUID[],
    related_ecosystems UUID[],

    -- Languages
    languages VARCHAR(50)[] DEFAULT ARRAY['en', 'es'],

    -- Access
    url TEXT,
    license VARCHAR(100) DEFAULT 'CC BY-SA 4.0',
    cost_usd NUMERIC(8,2) DEFAULT 0.00,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 8. INDEXES FOR PERFORMANCE
-- =====================================================

-- Taxonomy indexes
CREATE INDEX idx_taxonomy_scientific_name ON taxonomy USING GIN(scientific_name gin_trgm_ops);
CREATE INDEX idx_taxonomy_kingdom_class ON taxonomy(kingdom, class);

-- Species indexes
CREATE INDEX idx_species_taxonomy ON species(taxonomy_id);
CREATE INDEX idx_species_common_name ON species USING GIN(common_name gin_trgm_ops);
CREATE INDEX idx_species_endemic_status ON species(endemic_status);
CREATE INDEX idx_species_conservation_status ON species(conservation_status);
CREATE INDEX idx_species_rarity_score ON species(rarity_score DESC);

-- Spatial indexes
CREATE INDEX idx_ecosystems_geography ON ecosystems USING GIST(geography);
CREATE INDEX idx_observations_location ON species_observations USING GIST(location);
CREATE INDEX idx_ej_communities_boundary ON environmental_justice_communities USING GIST(boundary);

-- Time-series indexes
CREATE INDEX idx_population_history_species_year ON population_history(species_id, year DESC);
CREATE INDEX idx_observations_date ON species_observations(observation_date DESC);

-- Full-text search indexes
CREATE INDEX idx_species_description_fts ON species USING GIN(to_tsvector('english', description));
CREATE INDEX idx_cultural_knowledge_fts ON cultural_knowledge USING GIN(to_tsvector('english', traditional_use));

-- Conservation indexes
CREATE INDEX idx_species_threats_severity ON species_threats(species_id, severity);
CREATE INDEX idx_conservation_actions_species ON conservation_actions USING GIN(target_species);

-- Justice framework indexes
CREATE INDEX idx_ej_communities_sacrifice_zone ON environmental_justice_communities(sacrifice_zone) WHERE sacrifice_zone = true;
CREATE INDEX idx_ej_communities_poverty ON environmental_justice_communities(poverty_rate DESC);

-- Web3 indexes
CREATE INDEX idx_nft_metadata_species ON nft_metadata(species_id);
CREATE INDEX idx_nft_metadata_contract ON nft_metadata(contract_address, token_id);
CREATE INDEX idx_conservation_rewards_wallet ON conservation_rewards(user_wallet_address);

-- =====================================================
-- 9. VIEWS FOR COMMON QUERIES
-- =====================================================

-- Complete species information view
CREATE VIEW v_species_complete AS
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
    s.nft_ready
FROM species s
JOIN taxonomy t ON s.taxonomy_id = t.id;

-- Endangered species with habitat info
CREATE VIEW v_endangered_species_habitats AS
SELECT
    s.id AS species_id,
    s.common_name,
    t.scientific_name,
    s.conservation_status,
    s.population_estimate_min,
    s.population_estimate_max,
    e.name AS ecosystem_name,
    e.ecosystem_type,
    e.protection_status,
    sh.habitat_preference
FROM species s
JOIN taxonomy t ON s.taxonomy_id = t.id
LEFT JOIN species_habitats sh ON s.id = sh.species_id
LEFT JOIN ecosystems e ON sh.ecosystem_id = e.id
WHERE s.conservation_status IN ('critically_endangered', 'endangered', 'vulnerable')
ORDER BY
    CASE s.conservation_status
        WHEN 'critically_endangered' THEN 1
        WHEN 'endangered' THEN 2
        WHEN 'vulnerable' THEN 3
    END;

-- Environmental justice sacrifice zones
CREATE VIEW v_sacrifice_zones AS
SELECT
    community_name,
    municipality,
    population,
    poverty_rate,
    percent_minority,
    pollution_sources,
    superfund_sites,
    coal_ash_exposure,
    flood_risk,
    maria_damage_level,
    days_without_power_post_maria,
    community_organizing_active,
    organizing_groups
FROM environmental_justice_communities
WHERE sacrifice_zone = true
ORDER BY poverty_rate DESC;

-- Species with traditional knowledge
CREATE VIEW v_species_cultural_knowledge AS
SELECT
    s.common_name,
    t.scientific_name,
    s.taino_name,
    ck.knowledge_type,
    ck.traditional_use,
    ck.sensitivity_level,
    ck.cultural_significance,
    ck.public_access,
    ck.fpic_status
FROM species s
JOIN taxonomy t ON s.taxonomy_id = t.id
JOIN cultural_knowledge ck ON s.id = ck.species_id
WHERE ck.public_access = true
ORDER BY ck.cultural_significance DESC;

-- Conservation actions effectiveness
CREATE VIEW v_conservation_actions_summary AS
SELECT
    action_name,
    action_type,
    implementing_organization,
    start_date,
    end_date,
    ongoing,
    total_budget_usd,
    effectiveness,
    community_involvement,
    indigenous_leadership,
    cardinality(target_species) AS species_count,
    cardinality(target_ecosystems) AS ecosystem_count
FROM conservation_actions
ORDER BY start_date DESC;

-- Recent species observations (last 30 days)
CREATE VIEW v_recent_observations AS
SELECT
    s.common_name,
    t.scientific_name,
    so.observation_date,
    so.individual_count,
    ST_Y(so.location::geometry) AS latitude,
    ST_X(so.location::geometry) AS longitude,
    so.verified,
    so.observer_name
FROM species_observations so
JOIN species s ON so.species_id = s.id
JOIN taxonomy t ON s.taxonomy_id = t.id
WHERE so.observation_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY so.observation_date DESC;

-- =====================================================
-- 10. FUNCTIONS & TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply update trigger to relevant tables
CREATE TRIGGER update_species_updated_at BEFORE UPDATE ON species
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ecosystems_updated_at BEFORE UPDATE ON ecosystems
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cultural_knowledge_updated_at BEFORE UPDATE ON cultural_knowledge
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to calculate species rarity score
CREATE OR REPLACE FUNCTION calculate_rarity_score(
    p_endemic_status VARCHAR,
    p_conservation_status VARCHAR,
    p_population_estimate_max INTEGER
)
RETURNS NUMERIC AS $$
DECLARE
    score NUMERIC := 0;
BEGIN
    -- Base score for endemic status
    score := CASE p_endemic_status
        WHEN 'endemic_puerto_rico' THEN 40
        WHEN 'endemic_caribbean' THEN 30
        WHEN 'native' THEN 20
        WHEN 'introduced' THEN 5
        WHEN 'invasive' THEN 0
        ELSE 10
    END;

    -- Add conservation status score
    score := score + CASE p_conservation_status
        WHEN 'extinct' THEN 100
        WHEN 'critically_endangered' THEN 50
        WHEN 'endangered' THEN 40
        WHEN 'vulnerable' THEN 30
        WHEN 'near_threatened' THEN 20
        ELSE 10
    END;

    -- Add population score (lower population = higher rarity)
    IF p_population_estimate_max IS NOT NULL THEN
        score := score + CASE
            WHEN p_population_estimate_max < 50 THEN 30
            WHEN p_population_estimate_max < 200 THEN 25
            WHEN p_population_estimate_max < 500 THEN 20
            WHEN p_population_estimate_max < 1000 THEN 15
            WHEN p_population_estimate_max < 5000 THEN 10
            ELSE 5
        END;
    END IF;

    -- Cap at 100
    RETURN LEAST(score, 100);
END;
$$ LANGUAGE plpgsql;

-- Function to get species population trend
CREATE OR REPLACE FUNCTION get_population_trend(p_species_id UUID)
RETURNS TABLE(
    year INTEGER,
    population INTEGER,
    percent_change NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ph.year,
        ph.population_estimate,
        CASE
            WHEN LAG(ph.population_estimate) OVER (ORDER BY ph.year) IS NOT NULL
            THEN ROUND(
                ((ph.population_estimate - LAG(ph.population_estimate) OVER (ORDER BY ph.year))::NUMERIC
                / LAG(ph.population_estimate) OVER (ORDER BY ph.year)::NUMERIC * 100),
                2
            )
            ELSE NULL
        END AS percent_change
    FROM population_history ph
    WHERE ph.species_id = p_species_id
    ORDER BY ph.year;
END;
$$ LANGUAGE plpgsql;

-- Function to find species within radius of location
CREATE OR REPLACE FUNCTION species_near_location(
    p_latitude NUMERIC,
    p_longitude NUMERIC,
    p_radius_km NUMERIC
)
RETURNS TABLE(
    species_id UUID,
    common_name VARCHAR,
    scientific_name VARCHAR,
    distance_km NUMERIC,
    observation_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.id,
        s.common_name,
        t.scientific_name,
        ROUND(
            ST_Distance(
                so.location,
                ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography
            )::NUMERIC / 1000,
            2
        ) AS distance_km,
        COUNT(*)::BIGINT AS observation_count
    FROM species_observations so
    JOIN species s ON so.species_id = s.id
    JOIN taxonomy t ON s.taxonomy_id = t.id
    WHERE ST_DWithin(
        so.location,
        ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography,
        p_radius_km * 1000
    )
    GROUP BY s.id, s.common_name, t.scientific_name, distance_km
    ORDER BY distance_km;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 11. SAMPLE DATA INSERTION TEMPLATE
-- =====================================================

-- Example: Insert Puerto Rican Parrot
DO $$
DECLARE
    v_taxonomy_id INTEGER;
    v_species_id UUID;
BEGIN
    -- Insert taxonomy
    INSERT INTO taxonomy (
        kingdom, phylum, class, "order", family, genus, species, scientific_name, authority
    ) VALUES (
        'Animalia', 'Chordata', 'Aves', 'Psittaciformes', 'Psittacidae', 'Amazona', 'vittata',
        'Amazona vittata', '(Boddaert, 1783)'
    )
    RETURNING id INTO v_taxonomy_id;

    -- Insert species
    INSERT INTO species (
        taxonomy_id, common_name, common_name_spanish, taino_name,
        endemic_status, conservation_status, conservation_status_date,
        description, population_estimate_min, population_estimate_max,
        population_estimate_year, population_trend,
        cultural_value, ecological_value, rarity_score, nft_ready
    ) VALUES (
        v_taxonomy_id,
        'Puerto Rican Parrot',
        'Cotorra Puertorriqueña',
        'Iguaca',
        'endemic_puerto_rico',
        'critically_endangered',
        '2021-01-01',
        'The only native parrot species to Puerto Rico, this vibrant green bird once numbered in the millions but was reduced to just 13 individuals in 1975.',
        50, 200, 2021, 'increasing',
        95.0, 90.0, 98.0, true
    )
    RETURNING id INTO v_species_id;

    -- Insert population history
    INSERT INTO population_history (species_id, year, population_estimate, confidence_level, data_source) VALUES
    (v_species_id, 1975, 13, 'high', 'US Fish & Wildlife Service'),
    (v_species_id, 1985, 47, 'high', 'US Fish & Wildlife Service'),
    (v_species_id, 2000, 46, 'high', 'US Fish & Wildlife Service'),
    (v_species_id, 2010, 58, 'high', 'US Fish & Wildlife Service'),
    (v_species_id, 2021, 686, 'high', 'US Fish & Wildlife Service - includes wild and captive populations');

END $$;

-- =====================================================
-- 12. PERMISSIONS & SECURITY
-- =====================================================

-- Create roles
CREATE ROLE biodiv_readonly;
CREATE ROLE biodiv_contributor;
CREATE ROLE biodiv_admin;
CREATE ROLE cultural_knowledge_guardian;

-- Grant read-only access
GRANT SELECT ON ALL TABLES IN SCHEMA public TO biodiv_readonly;

-- Grant contributor access (can add observations, limited updates)
GRANT SELECT, INSERT ON species_observations TO biodiv_contributor;
GRANT SELECT, INSERT ON conservation_rewards TO biodiv_contributor;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO biodiv_contributor;

-- Grant admin access
GRANT ALL ON ALL TABLES IN SCHEMA public TO biodiv_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO biodiv_admin;

-- Restrict cultural knowledge access
REVOKE ALL ON cultural_knowledge FROM biodiv_readonly, biodiv_contributor;
GRANT SELECT ON cultural_knowledge TO cultural_knowledge_guardian WHERE public_access = true;
GRANT ALL ON cultural_knowledge TO biodiv_admin;

-- Row-level security for cultural knowledge
ALTER TABLE cultural_knowledge ENABLE ROW LEVEL SECURITY;

CREATE POLICY cultural_knowledge_public_access ON cultural_knowledge
    FOR SELECT
    USING (public_access = true);

CREATE POLICY cultural_knowledge_guardian_access ON cultural_knowledge
    FOR ALL
    USING (current_user IN (SELECT rolname FROM pg_roles WHERE rolname = 'cultural_knowledge_guardian'));

-- =====================================================
-- END OF SCHEMA
-- =====================================================

-- Version history
CREATE TABLE schema_version (
    version VARCHAR(20) PRIMARY KEY,
    applied_date TIMESTAMP DEFAULT NOW(),
    description TEXT
);

INSERT INTO schema_version (version, description) VALUES
    ('1.0.0', 'Initial comprehensive schema with PostGIS, justice framework, web3 integration, and cultural protocols');
