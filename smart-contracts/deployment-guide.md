# Smart Contract Deployment Guide for Base

This guide walks you through deploying the Borikén Biodiversity Knowledge Base smart contracts on Base blockchain.

## 📋 **Contract Overview**

### 🏗️ **Deployment Order:**
1. **BiodiversityRegistry** - Core species database
2. **BiodiversityNFT** - NFT collection for species
3. **ConservationDAO** - Community governance
4. **Governance Token** - Voting token (optional ERC20)

## 🚀 **Prerequisites**

### 🛠️ **Required Tools:**
```bash
npm install -g @remix-project/remixd
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers
npm install @openzeppelin/contracts
```

### 💰 **Base Network Setup:**
- **Network**: Base Mainnet or Base Sepolia (testnet)
- **RPC URL**: `https://mainnet.base.org` (mainnet) or `https://sepolia.base.org` (testnet)
- **Chain ID**: 8453 (mainnet) or 84532 (testnet)
- **Currency**: ETH
- **Explorer**: https://basescan.org

### 💸 **Estimated Costs (Base Mainnet):**
- **BiodiversityRegistry**: ~$50-80 
- **BiodiversityNFT**: ~$60-90
- **ConservationDAO**: ~$70-100
- **Total**: ~$180-270

## 📄 **Contract 1: BiodiversityRegistry**

### 🎯 **Purpose:**
Core database storing all species information with cultural compliance built-in.

### 🚀 **Deployment:**

```javascript
// scripts/deploy-registry.js
const { ethers } = require("hardhat");

async function main() {
  // Replace with actual conservation fund address
  const conservationFundAddress = "0x742d35Cc6634C0532925a3b8D45c0f9CF6abcd1F";
  
  const BiodiversityRegistry = await ethers.getContractFactory("BiodiversityRegistry");
  const registry = await BiodiversityRegistry.deploy(conservationFundAddress);
  
  await registry.deployed();
  
  console.log("BiodiversityRegistry deployed to:", registry.address);
  
  // Grant initial roles
  const [deployer] = await ethers.getSigners();
  
  // Grant cultural authority role to community representatives
  const culturalAuthority = "0x123..."; // Replace with actual address
  await registry.grantCulturalAuthority(culturalAuthority);
  
  // Grant knowledge holder roles
  const knowledgeHolder1 = "0x456..."; // Replace with actual address
  await registry.connect(culturalAuthority).grantKnowledgeHolder(knowledgeHolder1);
  
  console.log("Initial roles granted");
}
```

### 📊 **Initial Data Population:**

```javascript
// scripts/populate-species.js
async function populateSpecies(registryAddress) {
  const registry = await ethers.getContractAt("BiodiversityRegistry", registryAddress);
  
  // Register Iguaca (Puerto Rican Parrot)
  await registry.registerSpecies(
    "bird_001",                    // speciesId
    "Amazona vittata",             // scientificName
    "Puerto Rican Parrot",         // commonName
    "Iguaca",                      // tainoName
    "highest",                     // culturalSignificance
    ["ceremonial", "spiritual_messenger"], // traditionalUses
    "critically_endangered",       // conservationStatus
    ["rainforest", "mountain_forest"], // habitat
    true,                          // isEndemic
    100,                          // rarityScore
    100,                          // culturalValue
    95,                           // ecologicalValue
    10,                           // benefitPercentage (10%)
    false                         // isSacred
  );
  
  // Register Coquí
  await registry.registerSpecies(
    "amphibian_001",
    "Eleutherodactylus coqui",
    "Common Coquí",
    "Coquí",
    "highest",
    ["cultural_symbol", "night_music"],
    "stable",
    ["ubiquitous"],
    true,
    70,
    100,
    85,
    5, // 5% benefit sharing
    false
  );
  
  console.log("Species registered successfully");
}
```

## 🎨 **Contract 2: BiodiversityNFT**

### 🎯 **Purpose:**
NFT collection where each token represents a species with automatic benefit sharing.

### 🚀 **Deployment:**

```javascript
// scripts/deploy-nft.js
async function deployNFT(registryAddress) {
  const conservationFundAddress = "0x742d35Cc6634C0532925a3b8D45c0f9CF6abcd1F";
  
  const BiodiversityNFT = await ethers.getContractFactory("BiodiversityNFT");
  const nft = await BiodiversityNFT.deploy(
    registryAddress,           // BiodiversityRegistry address
    conservationFundAddress    // Conservation fund address
  );
  
  await nft.deployed();
  console.log("BiodiversityNFT deployed to:", nft.address);
  
  return nft.address;
}
```

### 🖼️ **Mint First NFTs:**

```javascript
// scripts/mint-initial-nfts.js
async function mintInitialNFTs(nftAddress) {
  const nft = await ethers.getContractAt("BiodiversityNFT", nftAddress);
  
  // Mint Iguaca NFT with payment for community benefits
  const mintPrice = ethers.utils.parseEther("0.01"); // 0.01 ETH
  
  await nft.mintSpeciesNFT(
    "bird_001",                                    // speciesId
    "ipfs://QmYourImageHashHere",                  // imageURI
    "0xRecipientAddress",                          // to
    { value: mintPrice }
  );
  
  console.log("Iguaca NFT minted with community benefits");
  
  // Mint Coquí NFT
  await nft.mintSpeciesNFT(
    "amphibian_001",
    "ipfs://QmCoquiImageHash", 
    "0xRecipientAddress",
    { value: mintPrice }
  );
  
  console.log("Coquí NFT minted");
}
```

## 🏛️ **Contract 3: ConservationDAO**

### 🎯 **Purpose:**
Community governance for conservation decisions with cultural protocols.

### 🚀 **Deployment:**

```javascript
// scripts/deploy-dao.js
async function deployDAO(registryAddress, tokenAddress) {
  const ConservationDAO = await ethers.getContractFactory("ConservationDAO");
  const dao = await ConservationDAO.deploy(
    registryAddress,    // BiodiversityRegistry
    tokenAddress        // Governance token (ERC20)
  );
  
  await dao.deployed();
  console.log("ConservationDAO deployed to:", dao.address);
  
  // Set initial cultural guardians
  const culturalGuardian = "0x789..."; // Replace with actual address
  await dao.grantRole(await dao.CULTURAL_GUARDIAN(), culturalGuardian);
  
  return dao.address;
}
```

### 🗳️ **Create First Proposal:**

```javascript
// scripts/create-proposal.js
async function createFirstProposal(daoAddress) {
  const dao = await ethers.getContractAt("ConservationDAO", daoAddress);
  
  await dao.createProposal(
    "Protect Iguaca Habitat in El Yunque",                    // title
    "Expand protected areas for Puerto Rican Parrot recovery", // description
    "bird_001",                                               // targetSpeciesId
    "habitat_protection",                                     // proposalType
    ethers.utils.parseEther("10"),                          // funding (10 ETH)
    12,                                                       // timelineMonths
    ["Restore 100 hectares", "Install nest boxes", "Monitor population"], // deliverables
    100                                                       // expectedImpact (hectares)
  );
  
  console.log("First conservation proposal created");
}
```

## 🔧 **Complete Deployment Script**

```javascript
// scripts/deploy-all.js
async function deployAll() {
  console.log("🚀 Starting Borikén Biodiversity deployment on Base...");
  
  // Step 1: Deploy Registry
  console.log("📊 Deploying BiodiversityRegistry...");
  const registryAddress = await deployRegistry();
  
  // Step 2: Populate initial species data
  console.log("📝 Populating initial species data...");
  await populateSpecies(registryAddress);
  
  // Step 3: Deploy NFT contract
  console.log("🎨 Deploying BiodiversityNFT...");
  const nftAddress = await deployNFT(registryAddress);
  
  // Step 4: Deploy governance token (optional)
  console.log("🪙 Deploying governance token...");
  const tokenAddress = await deployGovernanceToken();
  
  // Step 5: Deploy DAO
  console.log("🏛️ Deploying ConservationDAO...");
  const daoAddress = await deployDAO(registryAddress, tokenAddress);
  
  // Step 6: Mint initial NFTs
  console.log("🖼️ Minting initial NFTs...");
  await mintInitialNFTs(nftAddress);
  
  // Step 7: Create first proposal
  console.log("🗳️ Creating first conservation proposal...");
  await createFirstProposal(daoAddress);
  
  console.log("✅ Deployment complete!");
  console.log({
    registry: registryAddress,
    nft: nftAddress,
    dao: daoAddress,
    token: tokenAddress
  });
}

deployAll().catch(console.error);
```

## 🔍 **Verification on BaseScan**

### 📄 **Contract Verification:**

```bash
# Install verification plugin
npm install --save-dev @nomiclabs/hardhat-etherscan

# Verify BiodiversityRegistry
npx hardhat verify --network base <REGISTRY_ADDRESS> "<CONSERVATION_FUND_ADDRESS>"

# Verify BiodiversityNFT  
npx hardhat verify --network base <NFT_ADDRESS> "<REGISTRY_ADDRESS>" "<CONSERVATION_FUND_ADDRESS>"

# Verify ConservationDAO
npx hardhat verify --network base <DAO_ADDRESS> "<REGISTRY_ADDRESS>" "<TOKEN_ADDRESS>"
```

## 🎮 **Using Contracts in Your Game/DApp**

### 📱 **Frontend Integration:**

```javascript
// frontend/utils/contracts.js
import { ethers } from 'ethers';

const CONTRACTS = {
  registry: "0xYourRegistryAddress",
  nft: "0xYourNFTAddress", 
  dao: "0xYourDAOAddress"
};

// Get species data for game
export async function getSpeciesForGame(speciesId) {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const registry = new ethers.Contract(
    CONTRACTS.registry,
    registryABI,
    provider
  );
  
  try {
    const species = await registry.getSpecies(speciesId);
    return {
      name: species.tainoName,
      scientificName: species.scientificName,
      habitat: species.habitat,
      culturalSignificance: species.culturalSignificance,
      isEndemic: species.isEndemic
    };
  } catch (error) {
    if (error.message.includes("Sacred knowledge")) {
      return { error: "Sacred species requires community permission" };
    }
    throw error;
  }
}

// Mint NFT with cultural compliance
export async function mintSpeciesNFT(speciesId, imageURI, recipient) {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const nft = new ethers.Contract(CONTRACTS.nft, nftABI, signer);
  
  // Calculate mint price (includes community benefits)
  const mintPrice = ethers.utils.parseEther("0.01");
  
  const tx = await nft.mintSpeciesNFT(speciesId, imageURI, recipient, {
    value: mintPrice
  });
  
  return tx.wait();
}

// Create conservation proposal
export async function createConservationProposal(proposalData) {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const dao = new ethers.Contract(CONTRACTS.dao, daoABI, signer);
  
  const tx = await dao.createProposal(
    proposalData.title,
    proposalData.description,
    proposalData.targetSpecies,
    proposalData.type,
    ethers.utils.parseEther(proposalData.funding.toString()),
    proposalData.timeline,
    proposalData.deliverables,
    proposalData.expectedImpact
  );
  
  return tx.wait();
}
```

## 📈 **Current Repository Presentation to Base Protocol**

### ✅ **Strengths:**
1. **Complete JSON Database** - Ready for smart contract integration
2. **Cultural Compliance Built-In** - First blockchain biodiversity DB with Indigenous protocols
3. **NFT-Ready Metadata** - Automatic generation with cultural attribution
4. **DAO Governance** - Community-driven conservation decisions
5. **Benefit Sharing** - Automatic distribution to knowledge holders

### 🚀 **Base Protocol Alignment:**
- **Consumer-Focused**: Biodiversity gaming and education apps
- **Low-Cost**: Affordable for conservation organizations and communities
- **Developer-Friendly**: Easy integration with existing Base ecosystem
- **Social Impact**: Aligns with Base's mission of bringing next billion users on-chain

### 💡 **Potential Base Ecosystem Integrations:**
- **Farcaster**: Social updates about conservation efforts
- **Coinbase Wallet**: Easy NFT minting and governance participation
- **Base Names**: Conservation.base for easy discovery
- **Base Bridge**: Easy ETH deposits for conservation funding

## 🎯 **Next Steps:**

1. **Deploy on Base Sepolia** (testnet) first
2. **Test all contract interactions**
3. **Verify cultural compliance mechanisms**
4. **Deploy to Base Mainnet**
5. **Register with Base ecosystem**
6. **Launch conservation campaigns**

The repository is **exceptionally well-positioned** for Base deployment with its combination of cultural respect, scientific accuracy, and web3-native architecture! 🌺🐸🦜