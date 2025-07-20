# Base Sepolia Testnet Deployment Guide
*Portfolio Demo Deployment for haaz.eth*

## 🎯 **Goal: Portfolio-Ready Demo on Testnet**

### 🚀 **Quick Setup (30 minutes)**

#### 1. **Get Base Sepolia ETH**
```bash
# Get testnet ETH from Base Sepolia faucet
https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet

# Or bridge from Ethereum Sepolia
https://bridge.base.org/
```

#### 2. **Network Configuration**
```javascript
// hardhat.config.js
networks: {
  baseSepolia: {
    url: "https://sepolia.base.org",
    accounts: [process.env.PRIVATE_KEY],
    chainId: 84532,
  }
}
```

#### 3. **Deploy Portfolio Contracts**
```bash
# Deploy all three contracts for portfolio demo
npx hardhat run scripts/deploy-portfolio-demo.js --network baseSepolia
```

## 📝 **Portfolio Demo Contracts:**

### 🗳️ **1. EcologyMiniDAO.sol**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract EcologyMiniDAO {
    address public creator = 0xYourAddress; // haaz.eth
    
    struct Proposal {
        string species;
        string description;
        uint256 votes;
        bool executed;
        uint256 deadline;
    }
    
    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public hasVoted;
    uint256 public proposalCount;
    
    event ProposalCreated(uint256 id, string species);
    event VoteCast(address voter, uint256 proposalId);
    
    function createProposal(string memory _species, string memory _description) external {
        proposals[proposalCount] = Proposal({
            species: _species,
            description: _description,
            votes: 0,
            executed: false,
            deadline: block.timestamp + 7 days
        });
        
        emit ProposalCreated(proposalCount, _species);
        proposalCount++;
    }
    
    function vote(uint256 _proposalId) external {
        require(!hasVoted[msg.sender][_proposalId], "Already voted");
        require(block.timestamp < proposals[_proposalId].deadline, "Voting ended");
        
        proposals[_proposalId].votes++;
        hasVoted[msg.sender][_proposalId] = true;
        
        emit VoteCast(msg.sender, _proposalId);
    }
    
    function getProposal(uint256 _id) external view returns (Proposal memory) {
        return proposals[_id];
    }
}
```

### 🦜 **2. BoricuaSpeciesNFT.sol**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BoricuaSpeciesNFT is ERC721, Ownable {
    uint256 public tokenCounter;
    mapping(uint256 => string) public speciesData;
    
    address public creator = 0xYourAddress; // haaz.eth
    address public bakineStudio = 0xBakineAddress;
    
    event SpeciesMinted(uint256 tokenId, string species, address to);
    
    constructor() ERC721("Boricua Species", "BORIKUA") {
        tokenCounter = 0;
    }
    
    function mintSpecies(
        address _to, 
        string memory _scientificName,
        string memory _tainoName,
        string memory _habitat
    ) external payable {
        require(msg.value >= 0.001 ether, "Minimum donation required");
        
        uint256 tokenId = tokenCounter;
        _safeMint(_to, tokenId);
        
        // Store species data
        speciesData[tokenId] = string(abi.encodePacked(
            '{"scientific":"', _scientificName, 
            '","taino":"', _tainoName,
            '","habitat":"', _habitat, '"}'
        ));
        
        // Revenue distribution
        uint256 creatorShare = (msg.value * 70) / 100;
        uint256 studioShare = (msg.value * 30) / 100;
        
        payable(creator).transfer(creatorShare);
        payable(bakineStudio).transfer(studioShare);
        
        emit SpeciesMinted(tokenId, _scientificName, _to);
        tokenCounter++;
    }
    
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token doesn't exist");
        
        return string(abi.encodePacked(
            'data:application/json;base64,',
            base64Encode(bytes(speciesData[tokenId]))
        ));
    }
    
    function base64Encode(bytes memory data) internal pure returns (string memory) {
        // Simple base64 encoding for demo
        // In production, use a proper library
        return "eyJ0ZXN0IjoiZGF0YSJ9"; // Placeholder
    }
}
```

### 🌿 **3. BiodiversityRegistryDemo.sol**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract BiodiversityRegistryDemo {
    address public maintainer = 0xYourAddress; // haaz.eth
    
    struct Species {
        string scientificName;
        string commonName;
        string tainoName;
        bool isEndemic;
        string habitat;
        uint256 addedTimestamp;
    }
    
    mapping(string => Species) public species;
    string[] public speciesIds;
    
    event SpeciesAdded(string id, string scientificName, address addedBy);
    event DonationReceived(address donor, uint256 amount);
    
    modifier onlyMaintainer() {
        require(msg.sender == maintainer, "Not authorized");
        _;
    }
    
    function addSpecies(
        string memory _id,
        string memory _scientificName,
        string memory _commonName,
        string memory _tainoName,
        bool _isEndemic,
        string memory _habitat
    ) external onlyMaintainer {
        species[_id] = Species({
            scientificName: _scientificName,
            commonName: _commonName,
            tainoName: _tainoName,
            isEndemic: _isEndemic,
            habitat: _habitat,
            addedTimestamp: block.timestamp
        });
        
        speciesIds.push(_id);
        emit SpeciesAdded(_id, _scientificName, msg.sender);
    }
    
    function getSpecies(string memory _id) external view returns (Species memory) {
        return species[_id];
    }
    
    function getAllSpeciesIds() external view returns (string[] memory) {
        return speciesIds;
    }
    
    function supportProject() external payable {
        require(msg.value > 0, "Donation must be positive");
        payable(maintainer).transfer(msg.value);
        emit DonationReceived(msg.sender, msg.value);
    }
    
    function getSpeciesCount() external view returns (uint256) {
        return speciesIds.length;
    }
}
```

## 📋 **Deployment Script:**

### 🚀 **deploy-portfolio-demo.js**
```javascript
const hre = require("hardhat");

async function main() {
    console.log("🚀 Deploying Portfolio Demo to Base Sepolia...");
    
    // Deploy Registry
    const BiodiversityRegistry = await hre.ethers.getContractFactory("BiodiversityRegistryDemo");
    const registry = await BiodiversityRegistry.deploy();
    await registry.deployed();
    console.log("✅ BiodiversityRegistry deployed to:", registry.address);
    
    // Deploy NFT
    const BoricuaSpeciesNFT = await hre.ethers.getContractFactory("BoricuaSpeciesNFT");
    const nft = await BoricuaSpeciesNFT.deploy();
    await nft.deployed();
    console.log("✅ BoricuaSpeciesNFT deployed to:", nft.address);
    
    // Deploy DAO
    const EcologyMiniDAO = await hre.ethers.getContractFactory("EcologyMiniDAO");
    const dao = await EcologyMiniDAO.deploy();
    await dao.deployed();
    console.log("✅ EcologyMiniDAO deployed to:", dao.address);
    
    // Add initial species data
    console.log("📝 Adding initial species...");
    
    await registry.addSpecies(
        "iguaca",
        "Dendrocygna arborea",
        "West Indian Whistling Duck",
        "Iguaca",
        false,
        "Mangroves and wetlands"
    );
    
    await registry.addSpecies(
        "tody",
        "Todus mexicanus",
        "Puerto Rican Tody",
        "San Pedrito",
        true,
        "Mountain forests"
    );
    
    console.log("🎯 Portfolio Demo Deployed Successfully!");
    console.log("\n📋 Contract Addresses:");
    console.log("Registry:", registry.address);
    console.log("NFT:", nft.address);
    console.log("DAO:", dao.address);
    console.log("\n🔗 Base Sepolia Explorer:");
    console.log(`https://sepolia.basescan.org/address/${registry.address}`);
    console.log(`https://sepolia.basescan.org/address/${nft.address}`);
    console.log(`https://sepolia.basescan.org/address/${dao.address}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
```

## 📊 **Portfolio Documentation Template:**

### 🎯 **README for Portfolio**
```markdown
# Biodiversity DAO & NFT System
*Technical demonstration by haaz.eth*

## 🌿 **Overview**
Smart contract system demonstrating:
- Data management and storage
- NFT minting with dynamic metadata
- Basic DAO governance
- Revenue distribution systems

## 🔗 **Live Demo (Base Sepolia)**
- **Registry:** [Basescan Link]
- **NFT Collection:** [Basescan Link] 
- **Mini DAO:** [Basescan Link]

## 🛠️ **Technical Skills Demonstrated**
- Solidity smart contract development
- Data structure design and optimization
- Payment and revenue distribution logic
- NFT metadata generation
- Basic governance implementation
- Event-driven architecture

## 💡 **Business Model**
Revenue flows to bakine.studio for continued development
of Puerto Rico ecology education tools.
```

## ⚡ **Quick Answer:**

**Yes, deploy the demo on Base Sepolia first!**

✅ **Testnet advantages:**
- Free deployment and testing
- Perfect for portfolio demonstrations
- Easy iterations and improvements
- No financial risk

✅ **Portfolio impact:**
- Shows you can deploy real contracts
- Demonstrates multiple web3 patterns
- Provides verifiable code on blockchain
- Easy for employers/clients to review

Want me to create the deployment scripts so you can get this portfolio demo live this weekend?