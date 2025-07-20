// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title BoricuaSpeciesNFT
 * @dev NFT collection representing Puerto Rico biodiversity
 * @author haaz.eth
 */
contract BoricuaSpeciesNFT is ERC721, Ownable {
    uint256 private _tokenIdCounter;
    
    address public creator;
    address public bakineStudio;
    uint256 public mintPrice = 0.005 ether;
    
    struct SpeciesMetadata {
        string scientificName;
        string commonName;
        string tainoName;
        string habitat;
        string conservationStatus;
        bool isEndemic;
        uint256 rarity; // 1-5 scale
    }
    
    mapping(uint256 => SpeciesMetadata) public speciesData;
    mapping(string => bool) public speciesExists;
    
    event SpeciesMinted(
        uint256 indexed tokenId, 
        string scientificName, 
        address indexed to,
        uint256 mintPrice
    );
    event SpeciesAdded(string scientificName, uint256 rarity);
    
    constructor() ERC721("Boricua Species Collection", "BORIKUA") Ownable(msg.sender) {
        creator = msg.sender;
        bakineStudio = msg.sender; // Initially set to creator
    }
    
    /**
     * @dev Mint a species NFT
     */
    function mintSpecies(
        string memory _scientificName,
        string memory _commonName,
        string memory _tainoName,
        string memory _habitat,
        string memory _conservationStatus,
        bool _isEndemic,
        uint256 _rarity
    ) external payable {
        require(msg.value >= mintPrice, "Insufficient payment");
        require(_rarity >= 1 && _rarity <= 5, "Invalid rarity");
        require(!speciesExists[_scientificName], "Species already minted");
        
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        
        // Store metadata
        speciesData[tokenId] = SpeciesMetadata({
            scientificName: _scientificName,
            commonName: _commonName,
            tainoName: _tainoName,
            habitat: _habitat,
            conservationStatus: _conservationStatus,
            isEndemic: _isEndemic,
            rarity: _rarity
        });
        
        speciesExists[_scientificName] = true;
        
        // Mint to sender
        _safeMint(msg.sender, tokenId);
        
        // Distribute payment
        _distributePayment(msg.value);
        
        emit SpeciesMinted(tokenId, _scientificName, msg.sender, msg.value);
        emit SpeciesAdded(_scientificName, _rarity);
    }
    
    /**
     * @dev Owner mint for initial collection
     */
    function ownerMint(
        address _to,
        string memory _scientificName,
        string memory _commonName,
        string memory _tainoName,
        string memory _habitat,
        string memory _conservationStatus,
        bool _isEndemic,
        uint256 _rarity
    ) external onlyOwner {
        require(_rarity >= 1 && _rarity <= 5, "Invalid rarity");
        require(!speciesExists[_scientificName], "Species already minted");
        
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        
        // Store metadata
        speciesData[tokenId] = SpeciesMetadata({
            scientificName: _scientificName,
            commonName: _commonName,
            tainoName: _tainoName,
            habitat: _habitat,
            conservationStatus: _conservationStatus,
            isEndemic: _isEndemic,
            rarity: _rarity
        });
        
        speciesExists[_scientificName] = true;
        _safeMint(_to, tokenId);
        
        emit SpeciesAdded(_scientificName, _rarity);
    }
    
    /**
     * @dev Generate metadata JSON for token
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        
        SpeciesMetadata memory species = speciesData[tokenId];
        
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"', species.scientificName, '",',
                        '"description":"Puerto Rico biodiversity NFT - ', species.commonName, '",',
                        '"attributes":[',
                        '{"trait_type":"Scientific Name","value":"', species.scientificName, '"},',
                        '{"trait_type":"Common Name","value":"', species.commonName, '"},',
                        '{"trait_type":"Taino Name","value":"', species.tainoName, '"},',
                        '{"trait_type":"Habitat","value":"', species.habitat, '"},',
                        '{"trait_type":"Conservation Status","value":"', species.conservationStatus, '"},',
                        '{"trait_type":"Endemic","value":"', species.isEndemic ? "Yes" : "No", '"},',
                        '{"trait_type":"Rarity","value":', _toString(species.rarity), '}',
                        '],',
                        '"image":"data:image/svg+xml;base64,', _generateSVG(tokenId), '"',
                        '}'
                    )
                )
            )
        );
        
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
    
    /**
     * @dev Generate simple SVG for demonstration
     */
    function _generateSVG(uint256 tokenId) internal view returns (string memory) {
        SpeciesMetadata memory species = speciesData[tokenId];
        
        string memory svg = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '<svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">',
                        '<rect width="400" height="400" fill="#006940"/>',
                        '<text x="200" y="150" text-anchor="middle" fill="white" font-size="14">',
                        species.scientificName,
                        '</text>',
                        '<text x="200" y="180" text-anchor="middle" fill="#FFD700" font-size="12">',
                        species.tainoName,
                        '</text>',
                        '<text x="200" y="220" text-anchor="middle" fill="white" font-size="10">',
                        species.isEndemic ? "Endemic to Borik\xC3\xA9n" : "Native Species",
                        '</text>',
                        '<text x="200" y="280" text-anchor="middle" fill="white" font-size="8">',
                        "Rarity: ", _toString(species.rarity), "/5",
                        '</text>',
                        '</svg>'
                    )
                )
            )
        );
        
        return svg;
    }
    
    /**
     * @dev Distribute payment between creator and bakine studio
     */
    function _distributePayment(uint256 amount) internal {
        uint256 creatorShare = (amount * 70) / 100;
        uint256 studioShare = amount - creatorShare;
        
        payable(creator).transfer(creatorShare);
        payable(bakineStudio).transfer(studioShare);
    }
    
    /**
     * @dev Convert uint to string
     */
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
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
     * @dev Update mint price
     */
    function setMintPrice(uint256 _newPrice) external onlyOwner {
        mintPrice = _newPrice;
    }
    
    /**
     * @dev Update bakine studio address
     */
    function setBakineStudio(address _bakineStudio) external onlyOwner {
        bakineStudio = _bakineStudio;
    }
    
    /**
     * @dev Get total supply
     */
    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter;
    }
    
    /**
     * @dev Get species metadata
     */
    function getSpeciesData(uint256 tokenId) external view returns (SpeciesMetadata memory) {
        _requireOwned(tokenId);
        return speciesData[tokenId];
    }
    
    /**
     * @dev Emergency withdraw
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        _distributePayment(balance);
    }
}