// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title BiodiversityRegistrySimple
 * @dev Simplified biodiversity database for Base - First deployment version
 * @notice World's first Indigenous-controlled biodiversity blockchain database
 */
contract BiodiversityRegistrySimple {
    
    // Simple species structure - directly maps to your JSON
    struct Species {
        string speciesId;           // "bird_001", "amphibian_001"
        string scientificName;      // "Amazona vittata"
        string tainoName;          // "Iguaca"
        string culturalSignificance; // "highest", "high", "moderate"
        bool isEndemic;            // true for Puerto Rico endemics
        uint256 rarityScore;       // 1-100, matches your JSON
        address knowledgeHolder;   // Who contributed this knowledge
        uint256 registeredAt;      // When added to blockchain
    }
    
    // Storage
    mapping(string => Species) public species;
    mapping(address => uint256) public contributorEarnings;
    
    // Simple access control
    address public admin;
    mapping(address => bool) public knowledgeContributors;
    
    // Events for transparency
    event SpeciesRegistered(string indexed speciesId, string tainoName, address contributor);
    event KnowledgeUsed(string indexed speciesId, address user, uint256 payment);
    event EarningsWithdrawn(address contributor, uint256 amount);
    
    constructor() {
        admin = msg.sender;
        knowledgeContributors[msg.sender] = true; // Admin can add initial species
    }
    
    /**
     * @dev Register a species from your JSON database
     * @notice This preserves traditional knowledge on blockchain forever
     */
    function registerSpecies(
        string memory _speciesId,
        string memory _scientificName,
        string memory _tainoName,
        string memory _culturalSignificance,
        bool _isEndemic,
        uint256 _rarityScore
    ) external {
        require(knowledgeContributors[msg.sender], "Not authorized to contribute knowledge");
        require(bytes(species[_speciesId].speciesId).length == 0, "Species already exists");
        require(_rarityScore <= 100, "Rarity score must be 1-100");
        
        species[_speciesId] = Species({
            speciesId: _speciesId,
            scientificName: _scientificName,
            tainoName: _tainoName,
            culturalSignificance: _culturalSignificance,
            isEndemic: _isEndemic,
            rarityScore: _rarityScore,
            knowledgeHolder: msg.sender,
            registeredAt: block.timestamp
        });
        
        emit SpeciesRegistered(_speciesId, _tainoName, msg.sender);
    }
    
    /**
     * @dev Get species information (free for educational use)
     * @notice Anyone can access this knowledge for learning
     */
    function getSpecies(string memory _speciesId) external view returns (Species memory) {
        require(bytes(species[_speciesId].speciesId).length > 0, "Species not found");
        return species[_speciesId];
    }
    
    /**
     * @dev Use species knowledge commercially - pays the knowledge holder
     * @notice Revolutionary: Traditional knowledge holders get paid automatically!
     */
    function useKnowledgeCommercially(string memory _speciesId) external payable {
        require(msg.value > 0, "Payment required for commercial use");
        require(bytes(species[_speciesId].speciesId).length > 0, "Species not found");
        
        Species memory sp = species[_speciesId];
        
        // 70% to knowledge holder, 30% stays in contract for development
        uint256 holderPayment = (msg.value * 70) / 100;
        contributorEarnings[sp.knowledgeHolder] += holderPayment;
        
        emit KnowledgeUsed(_speciesId, msg.sender, msg.value);
    }
    
    /**
     * @dev Knowledge holders can withdraw their earnings
     * @notice Direct economic benefit to Indigenous communities
     */
    function withdrawEarnings() external {
        uint256 amount = contributorEarnings[msg.sender];
        require(amount > 0, "No earnings to withdraw");
        
        contributorEarnings[msg.sender] = 0;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit EarningsWithdrawn(msg.sender, amount);
    }
    
    /**
     * @dev Get stats about the database
     */
    function getDatabaseStats() external view returns (uint256 totalSpecies, uint256 totalEarnings) {
        // Simple version - would need counters in production
        return (0, address(this).balance); // Placeholder for demo
    }
    
    /**
     * @dev Generate simple NFT metadata for a species
     * @notice Returns JSON that can be used by NFT marketplaces
     */
    function generateNFTMetadata(string memory _speciesId) external view returns (string memory) {
        Species memory sp = species[_speciesId];
        require(bytes(sp.speciesId).length > 0, "Species not found");
        
        return string(abi.encodePacked(
            '{"name":"', sp.tainoName, ' (', sp.scientificName, ')",',
            '"description":"Endemic species from Borikén (Puerto Rico) - Traditional knowledge preserved on blockchain",',
            '"attributes":[',
                '{"trait_type":"Scientific Name","value":"', sp.scientificName, '"},',
                '{"trait_type":"Taíno Name","value":"', sp.tainoName, '"},',
                '{"trait_type":"Endemic","value":"', sp.isEndemic ? "Yes" : "No", '"},',
                '{"trait_type":"Cultural Significance","value":"', sp.culturalSignificance, '"},',
                '{"trait_type":"Rarity Score","value":"', _uint2str(sp.rarityScore), '"}',
            '],',
            '"cultural_protocol":"Traditional knowledge of the Taíno people - Commercial use requires payment to knowledge holders"',
            '}'
        ));
    }
    
    // Admin functions
    function addKnowledgeContributor(address _contributor) external {
        require(msg.sender == admin, "Only admin");
        knowledgeContributors[_contributor] = true;
    }
    
    // Helper function
    function _uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) return "0";
        
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}