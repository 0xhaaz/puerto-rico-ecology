# Borikén Biodiversity 🌿

> An ecological research dataset and smart contract exploration for Puerto Rico biodiversity — built as a learning project and game development context, with care for Taíno heritage.

[![Solidity](https://img.shields.io/badge/Solidity-^0.8.20-blue.svg)](https://soliditylang.org/)
[![Hardhat](https://img.shields.io/badge/Framework-Hardhat-orange.svg)](https://hardhat.org/)
[![Base](https://img.shields.io/badge/Network-Base%20Sepolia-blue.svg)](https://base.org/)

**Developer:** [haaz.eth](https://base.org) | **Studio:** [bakine.studio](https://bakine.studio)

## 🌱 What This Project Is

This repo explores a question: *what would it look like to use smart contracts for biodiversity data stewardship rather than financial speculation?*

It combines:
- **Ecological research data** on Puerto Rico / Borikén's species, ecosystems, and conservation status
- **Taíno cultural knowledge** connecting Indigenous ecological understanding to modern data formats
- **Solidity smart contracts** exploring on-chain data registration, NFT minting, and community governance
- **Game development context** — species data and mechanics designed for use in creative/game projects

This is a learning project, not a production system. The contracts have not been deployed; they are here to demonstrate Solidity development skills and to explore how blockchain technology might serve ecological data preservation and cultural heritage.

## 🌿 Ecological Research Content

The `data/` directory is the heart of this repo — genuine ecological research organized for both technical and creative use:

```
data/
├── biodiversity/           # Flora, fauna, and conservation overview
├── coqui/                  # The iconic coqui frog — species, habitat, sounds
├── ecosystems/             # Rainforest, coastal, and urban ecosystems
├── species/
│   ├── vertebrates/        # Endemic birds, reptiles, marine fish
│   ├── invertebrates/      # Endemic beetles and insects
│   ├── plants/             # Sacred trees, medicinal herbs
│   └── fungi/              # Culturally significant fungi
├── conservation-status/    # Threatened species action plans
├── cultural-connections/   # Taíno ecological knowledge
└── api-ready/              # Species database in JSON for web3 integration
```

The `game-context/` directory includes guides and mechanics for using this ecological data in game design:
- `GAME_GUIDE.md` — overview of how species data maps to game mechanics
- `mechanics/QUICK_REFERENCE.md` — quick reference for game designers

The `references/` directory holds source materials and citations.

## 🌺 Cultural and Ethical Context

Working with Puerto Rico's biodiversity means working with Taíno ecological knowledge — a living heritage, not a historical artifact. The data in this project draws on Indigenous naming conventions, ecological relationships, and cultural significance that the Taíno people have tended for generations.

This project approaches that material with the understanding that:
- Indigenous knowledge systems deserve attribution and respect, not extraction
- Blockchain technology *could* serve as a tool for community-controlled data stewardship
- Any real deployment of these ideas should involve the communities whose heritage is represented

The `data/cultural-connections/taino_ecological_knowledge.md` file documents the connections between Taíno knowledge and the species data in this repo.

## 🏗️ Smart Contracts

The contracts explore what on-chain biodiversity data management might look like:

```
contracts/
├── BiodiversityRegistryDemo.sol    # Species data registration on-chain
├── BoricuaSpeciesNFT.sol          # ERC-721 NFTs with SVG metadata
└── EcologyMiniDAO.sol             # Community governance and voting
```

**Key technical features:**
- Gas-optimized with IR compilation and efficient storage patterns
- OpenZeppelin v5 for access control and ERC standards
- Role-based permissions for data stewardship
- On-chain SVG metadata generation

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

# Deploy to Base Sepolia (testnet only — no mainnet deployment exists)
npm run deploy:sepolia
```

## 📋 Deployment Instructions (Base Sepolia)

These contracts have not been deployed. To deploy your own instance:

| Contract | Purpose | Command |
|----------|---------|---------|
| 🌿 **BiodiversityRegistry** | Species database | `npm run deploy:sepolia` |
| 🦜 **BoricuaSpeciesNFT** | NFT collection | `npm run deploy:sepolia` |
| 🗳️ **EcologyMiniDAO** | Governance system | `npm run deploy:sepolia` |

## 🔧 Development Commands

```bash
npm run compile         # Compile contracts
npm run test           # Run test suite
npm run deploy:sepolia # Deploy to Base Sepolia testnet
npm run deploy:base    # Deploy to Base mainnet
npm run verify         # Verify on BaseScan
```

## 💡 Proposed Revenue Structure

The contracts include a revenue-splitting design (not currently active — no contracts are deployed):

```
Designed revenue split (in contract code):
├── 70% → haaz.eth (creator/developer)
└── 30% → bakine.studio (development fund)

Designed revenue sources:
├── NFT minting (0.005 ETH)
├── DAO membership (0.001 ETH)
└── Direct donations
```

This is a design decision in the contract code, not an active revenue stream.

## 📁 Project Structure

```
puerto-rico-ecology/
├── contracts/          # Solidity smart contracts
├── data/               # Ecological research data
├── game-context/       # Game design documentation and mechanics
├── assets/             # Images, sounds, game assets
├── references/         # Source materials and citations
├── scripts/deploy/     # Deployment scripts
├── test/               # Contract test files
├── hardhat.config.js   # Hardhat configuration
└── package.json        # Dependencies
```

## 🔍 What This Project Demonstrates

1. **Solidity Development** — Multi-contract architecture with Solidity 0.8.20+ and OpenZeppelin v5
2. **Multi-contract Design** — Registry, NFT (ERC-721), and DAO governance working together
3. **Ecological Data Modeling** — Structuring real-world biodiversity data for on-chain use
4. **Cultural Sensitivity** — Approaching Indigenous ecological knowledge with care and attribution
5. **L2 Ecosystem Familiarity** — Hardhat configuration for Base / Base Sepolia deployment

## 🤝 Contact

- **Developer:** haaz.eth
- **Studio:** [bakine.studio](https://bakine.studio)
- **Network:** Base Ecosystem

## 📄 License

MIT License — see [LICENSE](LICENSE) file.

---

**Built with ❤️ for Borikén biodiversity, Taíno heritage, and the curiosity of what technology could do in service of the living world.**