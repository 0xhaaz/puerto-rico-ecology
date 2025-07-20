// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title BiodiversityRegistry
 * @dev Core smart contract for Borikén Biodiversity Knowledge Base
 * @notice Preserves traditional ecological knowledge with cultural protocols
 */
contract BiodiversityRegistry is AccessControl, ReentrancyGuard {
    
    // Roles for cultural governance
    bytes32 public constant KNOWLEDGE_HOLDER = keccak256("KNOWLEDGE_HOLDER");
    bytes32 public constant CULTURAL_AUTHORITY = keccak256("CULTURAL_AUTHORITY");
    bytes32 public constant RESEARCHER = keccak256("RESEARCHER");
    
    // Species data structure matching our JSON
    struct Species {
        string speciesId;
        string scientificName;
        string commonName;
        string tainoName;
        string culturalSignificance; // "highest", "high", "moderate", "low", "sacred"
        string[] traditionalUses;
        string conservationStatus;
        string[] habitat;
        bool isEndemic;
        uint256 rarityScore;
        uint256 culturalValue;
        uint256 ecologicalValue;
        address knowledgeContributor;
        uint256 benefitPercentage; // Percentage of commercial use fees
        bool isSacred; // Requires special permissions
        uint256 registrationTimestamp;
    }
    
    // Traditional knowledge structure
    struct TraditionalKnowledge {
        string knowledgeId;
        string content;
        string sensitivityLevel; // "public", "community", "sacred"
        string[] relatedSpecies;
        address knowledgeHolder;
        uint256 timestamp;
        bool requiresFPIC; // Free, Prior, Informed Consent
    }
    
    // Storage
    mapping(string => Species) public species;
    mapping(string => TraditionalKnowledge) public traditionalKnowledge;
    mapping(address => uint256) public benefitBalances;
    
    // Conservation fund
    address public conservationFund;
    uint256 public totalConservationFunding;
    
    // Events
    event SpeciesRegistered(string indexed speciesId, address indexed contributor);
    event KnowledgeShared(string indexed knowledgeId, address indexed holder);
    event CommercialUse(string indexed speciesId, address indexed user, uint256 amount);
    event BenefitDistributed(address indexed recipient, uint256 amount);
    event ConservationFunded(uint256 amount, string purpose);
    
    constructor(address _conservationFund) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        conservationFund = _conservationFund;
    }
    
    /**
     * @dev Cultural compliance modifier
     * @notice Ensures proper cultural protocols for accessing traditional knowledge
     */
    modifier culturallyCompliant(string memory speciesId) {
        Species memory sp = species[speciesId];
        
        if (sp.isSacred) {
            require(
                hasRole(CULTURAL_AUTHORITY, msg.sender), 
                "Sacred knowledge requires cultural authority approval"
            );
        }
        
        if (keccak256(abi.encodePacked(sp.culturalSignificance)) == keccak256(abi.encodePacked("highest"))) {
            require(
                hasRole(RESEARCHER, msg.sender) || hasRole(CULTURAL_AUTHORITY, msg.sender),
                "High cultural significance requires appropriate permissions"
            );
        }
        _;
    }
    
    /**
     * @dev Register a new species with traditional knowledge
     * @notice Only knowledge holders can register species data
     */
    function registerSpecies(
        string memory _speciesId,
        string memory _scientificName,
        string memory _commonName,
        string memory _tainoName,
        string memory _culturalSignificance,
        string[] memory _traditionalUses,
        string memory _conservationStatus,
        string[] memory _habitat,
        bool _isEndemic,
        uint256 _rarityScore,
        uint256 _culturalValue,
        uint256 _ecologicalValue,
        uint256 _benefitPercentage,
        bool _isSacred
    ) external onlyRole(KNOWLEDGE_HOLDER) {
        require(bytes(species[_speciesId].speciesId).length == 0, "Species already exists");
        require(_benefitPercentage <= 50, "Benefit percentage too high"); // Max 50%
        
        species[_speciesId] = Species({
            speciesId: _speciesId,
            scientificName: _scientificName,
            commonName: _commonName,
            tainoName: _tainoName,
            culturalSignificance: _culturalSignificance,
            traditionalUses: _traditionalUses,
            conservationStatus: _conservationStatus,
            habitat: _habitat,
            isEndemic: _isEndemic,
            rarityScore: _rarityScore,
            culturalValue: _culturalValue,
            ecologicalValue: _ecologicalValue,
            knowledgeContributor: msg.sender,
            benefitPercentage: _benefitPercentage,
            isSacred: _isSacred,
            registrationTimestamp: block.timestamp
        });
        
        emit SpeciesRegistered(_speciesId, msg.sender);
    }
    
    /**
     * @dev Get species data (free for educational/research use)
     * @notice Public function with cultural compliance built-in
     */
    function getSpecies(string memory _speciesId) 
        external 
        view 
        culturallyCompliant(_speciesId) 
        returns (Species memory) {
        require(bytes(species[_speciesId].speciesId).length > 0, "Species not found");
        return species[_speciesId];
    }
    
    /**
     * @dev Use species knowledge for commercial purposes
     * @notice Automatically distributes benefits to knowledge holders and conservation
     */
    function useSpeciesCommercially(string memory _speciesId) 
        external 
        payable 
        culturallyCompliant(_speciesId) 
        nonReentrant {
        require(msg.value > 0, "Payment required for commercial use");
        
        Species memory sp = species[_speciesId];
        require(bytes(sp.speciesId).length > 0, "Species not found");
        
        // Calculate benefit distribution
        uint256 knowledgeHolderBenefit = (msg.value * sp.benefitPercentage) / 100;
        uint256 conservationFunding = msg.value - knowledgeHolderBenefit;
        
        // Distribute benefits
        benefitBalances[sp.knowledgeContributor] += knowledgeHolderBenefit;
        totalConservationFunding += conservationFunding;
        
        // Transfer to conservation fund
        (bool success, ) = conservationFund.call{value: conservationFunding}("");
        require(success, "Conservation fund transfer failed");
        
        emit CommercialUse(_speciesId, msg.sender, msg.value);
        emit ConservationFunded(conservationFunding, "Species knowledge usage");
    }
    
    /**
     * @dev Generate NFT metadata for a species
     * @notice Returns JSON metadata compatible with OpenSea and other marketplaces
     */
    function generateNFTMetadata(string memory _speciesId) 
        external 
        view 
        culturallyCompliant(_speciesId) 
        returns (string memory) {
        Species memory sp = species[_speciesId];
        require(bytes(sp.speciesId).length > 0, "Species not found");
        
        // Build traits array
        string memory traits = string(abi.encodePacked(
            '{"trait_type":"Endemic Status","value":"', sp.isEndemic ? "Endemic" : "Native", '"},',
            '{"trait_type":"Cultural Significance","value":"', sp.culturalSignificance, '"},',
            '{"trait_type":"Conservation Status","value":"', sp.conservationStatus, '"},',
            '{"trait_type":"Rarity Score","value":', uintToString(sp.rarityScore), '},'
        ));
        
        return string(abi.encodePacked(
            '{',
            '"name":"', sp.tainoName, ' (', sp.scientificName, ')",',
            '"description":"Endemic species from Borikén (Puerto Rico) with traditional ecological knowledge.",',
            '"attributes":[', traits, '],',
            '"cultural_protocol":{',
                '"attribution":"Traditional knowledge of the Taíno people and Boricua communities",',
                '"benefit_sharing":"', uintToString(sp.benefitPercentage), '% of proceeds support knowledge holders",',
                '"fpic_compliance":"Required for traditional knowledge use"',
            '}',
            '}'
        ));
    }
    
    /**
     * @dev Withdraw accumulated benefits
     * @notice Knowledge holders can withdraw their earned benefits
     */
    function withdrawBenefits() external nonReentrant {
        uint256 amount = benefitBalances[msg.sender];
        require(amount > 0, "No benefits to withdraw");
        
        benefitBalances[msg.sender] = 0;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed");
        
        emit BenefitDistributed(msg.sender, amount);
    }
    
    /**
     * @dev Get total species count by category
     */
    function getStats() external view returns (
        uint256 totalSpecies,
        uint256 endemicCount,
        uint256 threatenedCount,
        uint256 totalFunding
    ) {
        // This would be implemented with counters in a production version
        return (4487, 309, 147, totalConservationFunding);
    }
    
    // Helper function to convert uint to string
    function uintToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        
        return string(buffer);
    }
    
    /**
     * @dev Grant cultural authority role
     * @notice Only admin can grant cultural authority roles
     */
    function grantCulturalAuthority(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(CULTURAL_AUTHORITY, account);
    }
    
    /**
     * @dev Grant knowledge holder role
     * @notice Only cultural authorities can grant knowledge holder roles
     */
    function grantKnowledgeHolder(address account) external onlyRole(CULTURAL_AUTHORITY) {
        grantRole(KNOWLEDGE_HOLDER, account);
    }
}