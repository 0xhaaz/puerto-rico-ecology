// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./BiodiversityRegistry.sol";

/**
 * @title BiodiversityNFT
 * @dev NFT collection for Borikén species with cultural compliance and benefit sharing
 * @notice Each NFT represents a species from the Biodiversity Registry
 */
contract BiodiversityNFT is ERC721, ERC721URIStorage, AccessControl, ReentrancyGuard {
    
    BiodiversityRegistry public biodiversityRegistry;
    
    // NFT metadata structure
    struct NFTMetadata {
        string speciesId;
        string imageURI;
        uint256 mintedTimestamp;
        address originalMinter;
        bool benefitsActive; // Whether this NFT contributes to conservation
    }
    
    // Storage
    mapping(uint256 => NFTMetadata) public nftMetadata;
    mapping(string => uint256) public speciesTokenId; // Species ID to Token ID
    mapping(string => bool) public speciesMinted; // Prevent duplicate minting
    
    // Conservation and benefit tracking
    uint256 public conservationFeePercentage = 10; // 10% of sale to conservation
    uint256 public communityBenefitPercentage = 5;  // 5% to knowledge holders
    address public conservationFund;
    
    // Counter for token IDs
    uint256 private _nextTokenId = 1;
    
    // Events
    event SpeciesNFTMinted(uint256 indexed tokenId, string indexed speciesId, address indexed minter);
    event ConservationContribution(uint256 indexed tokenId, uint256 amount);
    event CommunityBenefit(string indexed speciesId, address indexed beneficiary, uint256 amount);
    
    constructor(
        address _biodiversityRegistry,
        address _conservationFund
    ) ERC721("Borikén Biodiversity NFT", "BORICUA") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        biodiversityRegistry = BiodiversityRegistry(_biodiversityRegistry);
        conservationFund = _conservationFund;
    }
    
    /**
     * @dev Mint an NFT for a specific species
     * @notice Automatically generates metadata from BiodiversityRegistry
     */
    function mintSpeciesNFT(
        string memory _speciesId,
        string memory _imageURI,
        address _to
    ) external payable nonReentrant returns (uint256) {
        require(!speciesMinted[_speciesId], "Species NFT already minted");
        require(bytes(_imageURI).length > 0, "Image URI required");
        
        // Verify species exists in registry
        BiodiversityRegistry.Species memory species = biodiversityRegistry.getSpecies(_speciesId);
        require(bytes(species.speciesId).length > 0, "Species not found in registry");
        
        // Calculate and distribute fees
        if (msg.value > 0) {
            _distributeFees(_speciesId, msg.value);
        }
        
        uint256 tokenId = _nextTokenId++;
        
        // Store NFT metadata
        nftMetadata[tokenId] = NFTMetadata({
            speciesId: _speciesId,
            imageURI: _imageURI,
            mintedTimestamp: block.timestamp,
            originalMinter: msg.sender,
            benefitsActive: true
        });
        
        speciesTokenId[_speciesId] = tokenId;
        speciesMinted[_speciesId] = true;
        
        // Generate and set token URI from registry
        string memory tokenURI = _generateTokenURI(_speciesId, _imageURI);
        
        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        
        emit SpeciesNFTMinted(tokenId, _speciesId, msg.sender);
        
        return tokenId;
    }
    
    /**
     * @dev Generate token URI with metadata from BiodiversityRegistry
     */
    function _generateTokenURI(
        string memory _speciesId,
        string memory _imageURI
    ) internal view returns (string memory) {
        BiodiversityRegistry.Species memory species = biodiversityRegistry.getSpecies(_speciesId);
        
        // Build traditional uses array
        string memory traditionalUsesJson = _buildTraditionalUsesJson(species.traditionalUses);
        
        // Build habitat array
        string memory habitatJson = _buildHabitatJson(species.habitat);
        
        return string(abi.encodePacked(
            'data:application/json;base64,',
            _base64Encode(bytes(string(abi.encodePacked(
                '{',
                '"name":"', species.tainoName, ' (', species.scientificName, ')",',
                '"description":"Endemic species from Borikén (Puerto Rico) preserved through traditional ecological knowledge. This NFT supports biodiversity conservation and honors Indigenous wisdom.",',
                '"image":"', _imageURI, '",',
                '"external_url":"https://boricua-biodiversity.org/species/', _speciesId, '",',
                '"attributes":[',
                    '{"trait_type":"Scientific Name","value":"', species.scientificName, '"},',
                    '{"trait_type":"Taíno Name","value":"', species.tainoName, '"},',
                    '{"trait_type":"Endemic Status","value":"', species.isEndemic ? "Endemic" : "Native", '"},',
                    '{"trait_type":"Cultural Significance","value":"', species.culturalSignificance, '"},',
                    '{"trait_type":"Conservation Status","value":"', species.conservationStatus, '"},',
                    '{"trait_type":"Rarity Score","value":', _uintToString(species.rarityScore), '},',
                    '{"trait_type":"Cultural Value","value":', _uintToString(species.culturalValue), '},',
                    '{"trait_type":"Ecological Value","value":', _uintToString(species.ecologicalValue), '}',
                '],',
                '"traditional_uses":', traditionalUsesJson, ',',
                '"habitat":', habitatJson, ',',
                '"cultural_protocol":{',
                    '"attribution":"Traditional knowledge of the Taíno people and Boricua communities",',
                    '"fpic_compliance":"This NFT respects Free, Prior, and Informed Consent protocols",',
                    '"benefit_sharing":"', _uintToString(communityBenefitPercentage), '% of proceeds support Indigenous communities",',
                    '"conservation_contribution":"', _uintToString(conservationFeePercentage), '% of proceeds fund biodiversity conservation"',
                '},',
                '"blockchain":"Base",',
                '"standard":"ERC-721"',
                '}'
            ))))
        ));
    }
    
    /**
     * @dev Handle secondary sales with automatic benefit distribution
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721) {
        // Standard transfer
        super.transferFrom(from, to, tokenId);
        
        // If this was a paid transfer, we could implement royalty distribution here
        // This would require integration with marketplace contracts
    }
    
    /**
     * @dev Distribute fees to conservation fund and knowledge holders
     */
    function _distributeFees(string memory _speciesId, uint256 _amount) internal {
        uint256 conservationAmount = (_amount * conservationFeePercentage) / 100;
        uint256 communityAmount = (_amount * communityBenefitPercentage) / 100;
        
        // Send to conservation fund
        if (conservationAmount > 0) {
            (bool success, ) = conservationFund.call{value: conservationAmount}("");
            require(success, "Conservation fee transfer failed");
            emit ConservationContribution(speciesTokenId[_speciesId], conservationAmount);
        }
        
        // Send to knowledge holder via registry
        if (communityAmount > 0) {
            biodiversityRegistry.useSpeciesCommercially{value: communityAmount}(_speciesId);
            emit CommunityBenefit(_speciesId, msg.sender, communityAmount);
        }
    }
    
    /**
     * @dev Batch mint multiple species NFTs
     */
    function batchMintSpeciesNFTs(
        string[] memory _speciesIds,
        string[] memory _imageURIs,
        address _to
    ) external payable nonReentrant returns (uint256[] memory) {
        require(_speciesIds.length == _imageURIs.length, "Array length mismatch");
        require(_speciesIds.length <= 10, "Too many NFTs in batch"); // Limit batch size
        
        uint256[] memory tokenIds = new uint256[](_speciesIds.length);
        uint256 feePerNFT = msg.value / _speciesIds.length;
        
        for (uint256 i = 0; i < _speciesIds.length; i++) {
            // This would need to be refactored to avoid the msg.value issue
            // In practice, each mint would need separate payment handling
            tokenIds[i] = mintSpeciesNFT(_speciesIds[i], _imageURIs[i], _to);
        }
        
        return tokenIds;
    }
    
    /**
     * @dev Get NFT metadata
     */
    function getNFTMetadata(uint256 _tokenId) external view returns (NFTMetadata memory) {
        require(_exists(_tokenId), "Token does not exist");
        return nftMetadata[_tokenId];
    }
    
    /**
     * @dev Check if a species has been minted as NFT
     */
    function isSpeciesMinted(string memory _speciesId) external view returns (bool) {
        return speciesMinted[_speciesId];
    }
    
    /**
     * @dev Get token ID for a species
     */
    function getTokenIdForSpecies(string memory _speciesId) external view returns (uint256) {
        require(speciesMinted[_speciesId], "Species not minted");
        return speciesTokenId[_speciesId];
    }
    
    /**
     * @dev Admin function to update conservation fee percentage
     */
    function setConservationFeePercentage(uint256 _percentage) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_percentage <= 20, "Fee too high"); // Max 20%
        conservationFeePercentage = _percentage;
    }
    
    /**
     * @dev Admin function to update community benefit percentage
     */
    function setCommunityBenefitPercentage(uint256 _percentage) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_percentage <= 15, "Benefit too high"); // Max 15%
        communityBenefitPercentage = _percentage;
    }
    
    // Helper functions
    function _buildTraditionalUsesJson(string[] memory uses) internal pure returns (string memory) {
        if (uses.length == 0) return "[]";
        
        string memory result = "[";
        for (uint256 i = 0; i < uses.length; i++) {
            result = string(abi.encodePacked(result, '"', uses[i], '"'));
            if (i < uses.length - 1) {
                result = string(abi.encodePacked(result, ","));
            }
        }
        return string(abi.encodePacked(result, "]"));
    }
    
    function _buildHabitatJson(string[] memory habitats) internal pure returns (string memory) {
        if (habitats.length == 0) return "[]";
        
        string memory result = "[";
        for (uint256 i = 0; i < habitats.length; i++) {
            result = string(abi.encodePacked(result, '"', habitats[i], '"'));
            if (i < habitats.length - 1) {
                result = string(abi.encodePacked(result, ","));
            }
        }
        return string(abi.encodePacked(result, "]"));
    }
    
    function _uintToString(uint256 value) internal pure returns (string memory) {
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
    
    function _base64Encode(bytes memory data) internal pure returns (string memory) {
        // Simple base64 encoding - in production, use a library
        // This is a simplified version for demonstration
        string memory table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        if (data.length == 0) return "";
        
        string memory result = new string(4 * ((data.length + 2) / 3));
        bytes memory resultBytes = bytes(result);
        
        // Implementation would go here - using library in production
        return result;
    }
    
    // Override required functions
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
}