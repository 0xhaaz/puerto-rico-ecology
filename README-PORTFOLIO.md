# Borikén Biodiversity Portfolio Demo 🌿

*A technical demonstration by **haaz.eth** showcasing smart contract development skills through Puerto Rico biodiversity data.*

Revenue flows to **bakine.studio** for continued development.

## 🎯 **Portfolio Showcase**

This project demonstrates proficiency in:
- **Smart Contract Development** - Three interconnected contracts
- **Data Management** - Structured biodiversity database 
- **NFT Implementation** - Dynamic metadata and SVG generation
- **DAO Governance** - Voting and proposal mechanisms
- **Revenue Systems** - Automated payment distribution
- **Access Control** - Role-based permissions

## 📋 **Live Contracts (Base Sepolia)**

| Contract | Purpose | Address |
|----------|---------|---------|
| 🌿 **BiodiversityRegistry** | Species database | `[To be deployed]` |
| 🦜 **BoricuaSpeciesNFT** | NFT collection | `[To be deployed]` |
| 🗳️ **EcologyMiniDAO** | Governance system | `[To be deployed]` |

## 🚀 **Quick Deployment**

### Prerequisites
```bash
# 1. Get Base Sepolia testnet ETH
https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet

# 2. Install dependencies
npm install

# 3. Set up environment variables
cp .env.example .env
# Add your PRIVATE_KEY (without 0x prefix)
```

### Deploy to Base Sepolia
```bash
# Compile contracts
npm run compile

# Deploy to testnet (FREE)
npm run deploy:sepolia

# Verify contracts (optional)
npm run verify:sepolia [CONTRACT_ADDRESS]
```

## 🏗️ **Contract Architecture**

### 🌿 **BiodiversityRegistryDemo.sol**
```solidity
// Core data management
struct Species {
    string scientificName;
    string tainoName;
    bool isEndemic;
    uint256 rarity;
    // ... more fields
}

// Revenue distribution: 70% creator, 30% bakine.studio
function supportProject() external payable;
```

### 🦜 **BoricuaSpeciesNFT.sol**
```solidity
// NFT with embedded metadata
function mintSpecies(...) external payable;

// Dynamic SVG generation
function tokenURI(uint256 tokenId) public view returns (string memory);
```

### 🗳️ **EcologyMiniDAO.sol**
```solidity
// Community governance
function createProposal(string memory species, ...) external;
function vote(uint256 proposalId) external;
```

## 🎮 **Demo Features**

### **Species Database**
- ✅ 5 initial Puerto Rico species
- ✅ Endemic vs native classification
- ✅ Cultural names (Taíno/Spanish)
- ✅ Conservation status tracking
- ✅ Rarity scoring (1-5)

### **NFT Collection**
- ✅ Dynamic metadata generation
- ✅ SVG art with species data
- ✅ Automatic revenue distribution
- ✅ Unique species enforcement

### **Mini DAO**
- ✅ Membership through payment
- ✅ Species addition proposals
- ✅ Community voting system
- ✅ Proposal execution

## 💰 **Revenue Model**

```
Every transaction splits revenue:
├── 70% → haaz.eth (creator/maintainer)
└── 30% → bakine.studio (development fund)
```

**Use Cases:**
- NFT minting fees
- DAO membership fees
- Direct project support
- Contract interaction fees

## 🌟 **Technical Highlights**

### **Data Structures**
- Optimized storage layouts
- Gas-efficient mappings
- Indexed events for querying

### **Security Features**
- Access control modifiers
- Input validation
- Reentrancy protection
- Emergency withdrawal functions

### **User Experience**
- Base64-encoded metadata
- SVG art generation
- Event-driven updates
- Clear error messages

## 🎯 **Portfolio Impact**

### **For Employers/Clients**
This demonstrates real-world smart contract development including:

1. **Complex Data Management** - Handling structured biodiversity data
2. **Financial Systems** - Automated revenue distribution
3. **User Interaction** - NFTs, voting, membership systems
4. **Code Quality** - Clean, documented, tested Solidity

### **For Web3 Community**
Shows commitment to:
- **Meaningful Applications** - Beyond simple tokens
- **Cultural Sensitivity** - Respectful data handling
- **Revenue Transparency** - Clear fund distribution
- **Portfolio Building** - Honest scope and capabilities

## 🔗 **Links & Resources**

- **Creator:** [haaz.eth](https://base.build) 
- **Studio:** [bakine.studio](https://bakine.studio)
- **Base Sepolia Explorer:** [BaseScan](https://sepolia.basescan.org)
- **Base Testnet Faucet:** [Coinbase Faucet](https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet)

## 🛠️ **Development Stack**

- **Blockchain:** Base (Ethereum L2)
- **Smart Contracts:** Solidity 0.8.19
- **Development:** Hardhat
- **Libraries:** OpenZeppelin
- **Testing:** Chai + Hardhat
- **Verification:** BaseScan

## 📈 **Future Enhancements**

*This is positioned as a portfolio piece. Future development could include:*

- Mainnet deployment for real revenue
- Integration with Puerto Rico ecology game
- Partnership with conservation organizations
- Advanced DAO features (treasuries, governance tokens)
- IPFS metadata storage
- Mobile-friendly frontend

## 🤝 **Contributing**

This is a portfolio demonstration by haaz.eth. For collaboration inquiries, contact through bakine.studio.

---

**Built with ❤️ for Borikén biodiversity by haaz.eth**

*"Demonstrating web3 development skills through meaningful ecological data"*