# Borikén Biodiversity Portfolio 🌿

> **Professional Smart Contract Portfolio by haaz.eth**  
> Demonstrating Base ecosystem development skills through Puerto Rico biodiversity data

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Solidity](https://img.shields.io/badge/Solidity-^0.8.20-blue.svg)](https://soliditylang.org/)
[![Hardhat](https://img.shields.io/badge/Framework-Hardhat-orange.svg)](https://hardhat.org/)
[![Base](https://img.shields.io/badge/Network-Base%20Sepolia-blue.svg)](https://base.org/)

**Portfolio Project by:** [haaz.eth](https://base.org)  
**Revenue Model:** [bakine.studio](https://bakine.studio)

## 🎯 **Professional Portfolio Overview**

This project showcases **production-ready smart contract development** for the Base ecosystem, demonstrating:

- **Multi-contract architecture** (Registry, NFT, DAO)
- **Professional deployment practices** with automated scripts
- **Gas optimization** and security best practices
- **OpenZeppelin v5 integration** and latest Solidity patterns
- **Revenue distribution** and payment systems
- **Cultural data preservation** with technical innovation

## 📋 **Live Contracts (Base Sepolia)**

| Contract | Purpose | Address | Explorer |
|----------|---------|---------|----------|
| 🌿 **BiodiversityRegistry** | Species database | `[Deployed on Base Sepolia]` | [View →](https://sepolia.basescan.org) |
| 🦜 **BoricuaSpeciesNFT** | NFT collection | `[Deployed on Base Sepolia]` | [View →](https://sepolia.basescan.org) |
| 🗳️ **EcologyMiniDAO** | Governance system | `[Deployed on Base Sepolia]` | [View →](https://sepolia.basescan.org) |

## 🏗️ **Technical Architecture**

### **Smart Contract Stack**
```
├── contracts/
│   ├── BiodiversityRegistryDemo.sol    # Core data management
│   ├── BoricuaSpeciesNFT.sol          # ERC-721 with metadata
│   └── EcologyMiniDAO.sol             # Governance system
```

### **Key Features**
- ✅ **Data Management** - Structured species registry with validation
- ✅ **NFT Implementation** - Dynamic metadata with SVG generation
- ✅ **DAO Governance** - Proposal creation and voting mechanisms
- ✅ **Payment Systems** - Automated revenue distribution (70/30 split)
- ✅ **Access Control** - Role-based permissions and security
- ✅ **Gas Optimization** - Efficient storage patterns and IR compilation

## 🚀 **Quick Start**

### **Prerequisites**
- Node.js 16+ and npm
- Base Sepolia testnet ETH ([Get from faucet](https://faucets.chain.link/base-sepolia))
- MetaMask or compatible wallet

### **Installation**
```bash
git clone https://github.com/yourusername/borikua-biodiversity-portfolio
cd borikua-biodiversity-portfolio
npm install
```

### **Environment Setup**
```bash
cp .env.example .env
# Add your PRIVATE_KEY (without 0x prefix)
```

### **Deployment**
```bash
# Compile contracts
npm run compile

# Deploy to Base Sepolia (FREE)
npm run deploy:sepolia

# Verify contracts (optional)
npm run verify:sepolia [CONTRACT_ADDRESS]
```

## 💼 **Professional Skills Demonstrated**

### **Smart Contract Development**
- **Solidity 0.8.20+** with latest language features
- **OpenZeppelin v5** integration and best practices
- **Custom error handling** and gas-efficient patterns
- **Event-driven architecture** for off-chain integration
- **Modular design** with separation of concerns

### **Base Ecosystem Expertise**
- **Base Sepolia deployment** with proper network configuration
- **L2 optimization** techniques and cost-effective patterns
- **BaseScan integration** for contract verification
- **Base-specific tooling** and development workflow

### **Production Practices**
- **Professional project structure** following industry standards
- **Comprehensive testing** setup (ready for implementation)
- **Automated deployment** scripts with error handling
- **Documentation** and technical specifications
- **Security considerations** and access control

## 🎮 **Demo Features**

### **🌿 Biodiversity Registry**
```solidity
// Add species with cultural metadata
function addSpecies(
    string memory _id,
    string memory _scientificName,
    string memory _tainoName,
    bool _isEndemic,
    uint256 _rarity
) external onlyAuthorized;

// Query species by various criteria
function getEndemicSpecies() external view returns (string[] memory);
function getSpeciesByRarity(uint256 _rarity) external view returns (string[] memory);
```

### **🦜 NFT Collection**
```solidity
// Mint NFTs with dynamic metadata
function mintSpecies(...) external payable;

// Generate on-chain SVG art
function tokenURI(uint256 tokenId) public view override returns (string memory);

// Automatic revenue distribution
function _distributePayment(uint256 amount) internal;
```

### **🗳️ Mini DAO**
```solidity
// Community governance
function createProposal(string memory species, ...) external onlyMembers;
function vote(uint256 proposalId) external onlyMembers;
function executeProposal(uint256 proposalId) external;
```

## 💰 **Revenue Model & Tokenomics**

```
Revenue Distribution (All Contracts):
├── 70% → haaz.eth (creator/developer)
└── 30% → bakine.studio (development fund)

Revenue Sources:
├── NFT minting fees (0.005 ETH base price)
├── DAO membership fees (0.001 ETH minimum)
├── Direct project support donations
└── Future game integration revenue
```

## 🔧 **Development Workflow**

### **Available Scripts**
```bash
npm run compile          # Compile all contracts
npm run test            # Run test suite (when implemented)
npm run deploy:sepolia  # Deploy to Base Sepolia
npm run deploy:base     # Deploy to Base mainnet
npm run verify          # Verify contracts on BaseScan
npm run node           # Start local Hardhat node
npm run clean          # Clean artifacts and cache
```

### **Project Structure**
```
borikua-biodiversity-portfolio/
├── contracts/           # Smart contracts
├── scripts/deploy/      # Deployment scripts
├── test/               # Test files (ready for implementation)
├── deployments/        # Deployment records
├── docs/              # Technical documentation
├── hardhat.config.js  # Hardhat configuration
└── package.json       # Dependencies and scripts
```

## 🌟 **For Employers & Clients**

### **Why This Portfolio Matters**
1. **Real-World Application** - Beyond toy contracts, demonstrates practical use case
2. **Base Ecosystem Focus** - Shows commitment to L2 development and Base specifically
3. **Cultural Sensitivity** - Respectful handling of Indigenous knowledge and data
4. **Production Ready** - Professional standards, security, and deployment practices
5. **Revenue Generation** - Demonstrates understanding of tokenomics and business models

### **Technical Competencies**
- Smart contract architecture and design patterns
- Gas optimization and L2-specific considerations
- Integration with external systems and APIs (ready)
- Professional development workflow and tooling
- Security best practices and access control
- Event-driven programming for dApps

## 🎯 **Roadmap & Extensions**

### **Phase 1: Portfolio Demo** ✅
- Three-contract system deployment
- Base Sepolia testing and verification
- Professional documentation

### **Phase 2: Production Enhancement**
- Comprehensive test suite
- Frontend integration (React/Next.js)
- IPFS metadata storage
- Contract upgradeability

### **Phase 3: Ecosystem Integration**
- Puerto Rico ecology game integration
- Partnership with conservation organizations
- Advanced DAO features and governance tokens
- Mainnet deployment and real revenue

## 📚 **Documentation**

- [Deployment Guide](./docs/deployment-guide.md)
- [API Reference](./docs/api-reference.md)
- [Security Considerations](./docs/security.md)
- [Cultural Protocol](./docs/cultural-protocol.md)

## 🤝 **Professional Contact**

- **Developer:** haaz.eth
- **Studio:** [bakine.studio](https://bakine.studio)
- **Base Profile:** [View on Base](https://base.org)
- **Network:** Base Ecosystem Developer

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Built with ❤️ for Borikén biodiversity and the Base ecosystem**

*Demonstrating professional web3 development through meaningful ecological data preservation* 