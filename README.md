# Borikén Biodiversity 🌿

> Smart contracts and data infrastructure for Puerto Rican biodiversity — exploring how on-chain tools might serve ecological knowledge, indigenous data sovereignty, and community science.

[![Solidity](https://img.shields.io/badge/Solidity-^0.8.20-blue.svg)](https://soliditylang.org/)
[![Hardhat](https://img.shields.io/badge/Framework-Hardhat-orange.svg)](https://hardhat.org/)
[![Base](https://img.shields.io/badge/Network-Base%20Sepolia-blue.svg)](https://base.org/)

**Developer:** [0xhaaz](https://github.com/0xhaaz)

## Why This Exists

Puerto Rico's biodiversity is under compounding threat from climate disaster, colonial extraction, and displacement. This project explores how on-chain tools — registries, NFTs, and lightweight governance — might serve ecological knowledge in ways that center indigenous data sovereignty and community science rather than corporate extraction.

It asks: Who gets to define, record, and benefit from biodiversity data? What does it mean to put species data on-chain when the land those species live on is being sold out from under the communities that steward it?

This is a proof of concept built on Base Sepolia testnet, not a production system.

## 📋 Contracts (Base Sepolia Testnet)

| Contract | Purpose | Address |
|----------|---------|---------|
| 🌿 **BiodiversityRegistry** | Species database | `[Deploy with npm run deploy:sepolia]` |
| 🦜 **BoricuaSpeciesNFT** | NFT collection | `[Deploy with npm run deploy:sepolia]` |
| 🗳️ **EcologyMiniDAO** | Governance system | `[Deploy with npm run deploy:sepolia]` |

## 🚀 Quick Start

### Prerequisites
- Node.js 16+
- Base Sepolia testnet ETH ([Get from faucet](https://faucets.chain.link/base-sepolia))

### Installation & Deployment
```bash
git clone https://github.com/0xhaaz/puerto-rico-ecology.git
cd puerto-rico-ecology
npm install

# Set up environment
cp .env.example .env
# Add your PRIVATE_KEY (without 0x prefix)

# Deploy to Base Sepolia (FREE)
npm run deploy:sepolia
```

## 🏗️ Technical Architecture

### Smart Contracts
```
contracts/
├── BiodiversityRegistryDemo.sol    # Species data management
├── BoricuaSpeciesNFT.sol          # ERC-721 with SVG metadata
└── EcologyMiniDAO.sol             # Governance & voting
```

### Key Features
- ✅ **Gas Optimized** - IR compilation, efficient storage
- ✅ **OpenZeppelin v5** - Latest security standards
- ✅ **Access Control** - Role-based permissions
- ✅ **Cultural Respectful** - Indigenous data protocols

## 🔧 Development Commands

```bash
npm run compile         # Compile contracts
npm run test           # Run test suite
npm run deploy:sepolia # Deploy to Base Sepolia
npm run deploy:base    # Deploy to Base mainnet
npm run verify         # Verify on BaseScan
```

## 📁 Project Structure

```
puerto-rico-ecology/
├── contracts/          # Solidity smart contracts (Registry, NFT, DAO)
├── scripts/            # Deployment scripts
├── test/               # Contract tests
├── data/               # Ecological reference data
├── assets/             # Visual assets
├── references/         # Research references
├── game-context/       # Game development context (WIP)
└── hardhat.config.js   # Hardhat configuration
```

## 🔗 Related Work

- <a href="https://github.com/0xhaaz/Community-DeFi-Protocol">Community DeFi Protocol</a> — Mutual aid and spiritual labor recognition contracts
- <a href="https://github.com/0xhaaz/coqui-island-hopper">Coquí Island Hopper</a> — Interactive ecological education game
- <a href="https://github.com/0xhaaz/coqui-solitaire">Coquí Solitaire</a> — Puerto Rican-themed card game

## 🤝 Contact

- **Developer:** [0xhaaz](https://github.com/0xhaaz)

## 📄 License

MIT License - see [LICENSE](LICENSE) file.

---

**Built with ❤️ for Borikén biodiversity** 