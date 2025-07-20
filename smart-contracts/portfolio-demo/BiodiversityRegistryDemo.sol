// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title BiodiversityRegistryDemo
 * @dev Simple biodiversity database for portfolio demonstration
 * @author haaz.eth
 */
contract BiodiversityRegistryDemo {
    address public maintainer;
    address public bakineStudio;
    
    struct Species {
        string scientificName;
        string commonName;
        string tainoName;
        string habitat;
        string conservationStatus;
        bool isEndemic;
        bool isCharismatic;
        uint256 addedTimestamp;
        uint256 rarity; // 1-5 scale
    }
    
    mapping(string => Species) public species;
    string[] public speciesIds;
    mapping(address => bool) public authorizedContributors;
    
    uint256 public totalSpecies;
    uint256 public endemicCount;
    uint256 public totalDonations;
    
    event SpeciesAdded(
        string indexed id, 
        string scientificName, 
        address indexed addedBy
    );
    event DonationReceived(address indexed donor, uint256 amount);
    event ContributorAdded(address indexed contributor);
    event SpeciesUpdated(string indexed id, address indexed updatedBy);
    
    modifier onlyMaintainer() {
        require(msg.sender == maintainer, "Not authorized");
        _;
    }
    
    modifier onlyAuthorized() {
        require(
            msg.sender == maintainer || authorizedContributors[msg.sender], 
            "Not authorized"
        );
        _;
    }
    
    constructor() {
        maintainer = msg.sender;
        bakineStudio = msg.sender; // Initially set to creator
        authorizedContributors[msg.sender] = true;
    }
    
    /**
     * @dev Add a new species to the registry
     */
    function addSpecies(
        string memory _id,
        string memory _scientificName,
        string memory _commonName,
        string memory _tainoName,
        string memory _habitat,
        string memory _conservationStatus,
        bool _isEndemic,
        bool _isCharismatic,
        uint256 _rarity
    ) external onlyAuthorized {
        require(bytes(species[_id].scientificName).length == 0, "Species already exists");
        require(_rarity >= 1 && _rarity <= 5, "Invalid rarity score");
        
        species[_id] = Species({
            scientificName: _scientificName,
            commonName: _commonName,
            tainoName: _tainoName,
            habitat: _habitat,
            conservationStatus: _conservationStatus,
            isEndemic: _isEndemic,
            isCharismatic: _isCharismatic,
            addedTimestamp: block.timestamp,
            rarity: _rarity
        });
        
        speciesIds.push(_id);
        totalSpecies++;
        
        if (_isEndemic) {
            endemicCount++;
        }
        
        emit SpeciesAdded(_id, _scientificName, msg.sender);
    }
    
    /**
     * @dev Update existing species information
     */
    function updateSpecies(
        string memory _id,
        string memory _habitat,
        string memory _conservationStatus,
        uint256 _rarity
    ) external onlyAuthorized {
        require(bytes(species[_id].scientificName).length > 0, "Species doesn't exist");
        require(_rarity >= 1 && _rarity <= 5, "Invalid rarity score");
        
        species[_id].habitat = _habitat;
        species[_id].conservationStatus = _conservationStatus;
        species[_id].rarity = _rarity;
        
        emit SpeciesUpdated(_id, msg.sender);
    }
    
    /**
     * @dev Get species information
     */
    function getSpecies(string memory _id) external view returns (Species memory) {
        require(bytes(species[_id].scientificName).length > 0, "Species doesn't exist");
        return species[_id];
    }
    
    /**
     * @dev Get all species IDs
     */
    function getAllSpeciesIds() external view returns (string[] memory) {
        return speciesIds;
    }
    
    /**
     * @dev Get endemic species IDs
     */
    function getEndemicSpecies() external view returns (string[] memory) {
        string[] memory endemicSpecies = new string[](endemicCount);
        uint256 currentIndex = 0;
        
        for (uint256 i = 0; i < speciesIds.length; i++) {
            if (species[speciesIds[i]].isEndemic) {
                endemicSpecies[currentIndex] = speciesIds[i];
                currentIndex++;
            }
        }
        
        return endemicSpecies;
    }
    
    /**
     * @dev Get charismatic species IDs
     */
    function getCharismaticSpecies() external view returns (string[] memory) {
        uint256 charismaticCount = 0;
        
        // Count charismatic species
        for (uint256 i = 0; i < speciesIds.length; i++) {
            if (species[speciesIds[i]].isCharismatic) {
                charismaticCount++;
            }
        }
        
        string[] memory charismaticSpecies = new string[](charismaticCount);
        uint256 currentIndex = 0;
        
        for (uint256 i = 0; i < speciesIds.length; i++) {
            if (species[speciesIds[i]].isCharismatic) {
                charismaticSpecies[currentIndex] = speciesIds[i];
                currentIndex++;
            }
        }
        
        return charismaticSpecies;
    }
    
    /**
     * @dev Support project development
     */
    function supportProject() external payable {
        require(msg.value > 0, "Donation must be positive");
        
        totalDonations += msg.value;
        
        // Distribute payment
        uint256 maintainerShare = (msg.value * 70) / 100;
        uint256 studioShare = msg.value - maintainerShare;
        
        payable(maintainer).transfer(maintainerShare);
        payable(bakineStudio).transfer(studioShare);
        
        emit DonationReceived(msg.sender, msg.value);
    }
    
    /**
     * @dev Add authorized contributor
     */
    function addContributor(address _contributor) external onlyMaintainer {
        authorizedContributors[_contributor] = true;
        emit ContributorAdded(_contributor);
    }
    
    /**
     * @dev Remove contributor authorization
     */
    function removeContributor(address _contributor) external onlyMaintainer {
        authorizedContributors[_contributor] = false;
    }
    
    /**
     * @dev Update bakine studio address
     */
    function setBakineStudio(address _bakineStudio) external onlyMaintainer {
        bakineStudio = _bakineStudio;
    }
    
    /**
     * @dev Get registry statistics
     */
    function getStats() external view returns (
        uint256 _totalSpecies,
        uint256 _endemicCount,
        uint256 _totalDonations,
        uint256 _contributorCount
    ) {
        return (totalSpecies, endemicCount, totalDonations, speciesIds.length);
    }
    
    /**
     * @dev Get species by rarity level
     */
    function getSpeciesByRarity(uint256 _rarity) external view returns (string[] memory) {
        require(_rarity >= 1 && _rarity <= 5, "Invalid rarity");
        
        uint256 rarityCount = 0;
        
        // Count species with this rarity
        for (uint256 i = 0; i < speciesIds.length; i++) {
            if (species[speciesIds[i]].rarity == _rarity) {
                rarityCount++;
            }
        }
        
        string[] memory raritySpecies = new string[](rarityCount);
        uint256 currentIndex = 0;
        
        for (uint256 i = 0; i < speciesIds.length; i++) {
            if (species[speciesIds[i]].rarity == _rarity) {
                raritySpecies[currentIndex] = speciesIds[i];
                currentIndex++;
            }
        }
        
        return raritySpecies;
    }
    
    /**
     * @dev Check if species exists
     */
    function speciesExists(string memory _id) external view returns (bool) {
        return bytes(species[_id].scientificName).length > 0;
    }
    
    /**
     * @dev Get species count
     */
    function getSpeciesCount() external view returns (uint256) {
        return totalSpecies;
    }
    
    /**
     * @dev Emergency withdraw
     */
    function withdraw() external onlyMaintainer {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        uint256 maintainerShare = (balance * 70) / 100;
        uint256 studioShare = balance - maintainerShare;
        
        payable(maintainer).transfer(maintainerShare);
        payable(bakineStudio).transfer(studioShare);
    }
}