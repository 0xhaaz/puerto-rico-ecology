const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

/**
 * @title Base Sepolia Deployment Script
 * @dev Professional deployment for Borikén Biodiversity Portfolio
 * @author haaz.eth
 */
async function main() {
    console.log("🚀 Deploying Borikén Biodiversity Portfolio to Base Sepolia");
    console.log("═".repeat(60));
    
    const [deployer] = await hre.ethers.getSigners();
    
    console.log("📝 Deployment Details:");
    console.log(`   Network: ${hre.network.name}`);
    console.log(`   Deployer: ${deployer.address}`);
    console.log(`   Balance: ${hre.ethers.utils.formatEther(await deployer.getBalance())} ETH`);
    console.log(`   Chain ID: ${hre.network.config.chainId}`);
    console.log("");

    // Verify minimum balance
    const balance = await deployer.getBalance();
    const minBalance = hre.ethers.utils.parseEther("0.01");
    if (balance.lt(minBalance)) {
        console.error("❌ Insufficient balance for deployment");
        console.error(`   Required: 0.01 ETH minimum`);
        console.error(`   Current: ${hre.ethers.utils.formatEther(balance)} ETH`);
        console.error(`   Get testnet ETH: https://faucets.chain.link/base-sepolia`);
        process.exit(1);
    }

    const deploymentResults = {};
    
    try {
        // 1. Deploy BiodiversityRegistry
        console.log("🌿 Deploying BiodiversityRegistryDemo...");
        const BiodiversityRegistry = await hre.ethers.getContractFactory("BiodiversityRegistryDemo");
        const registry = await BiodiversityRegistry.deploy();
        await registry.deployed();
        
        deploymentResults.registry = {
            contract: "BiodiversityRegistryDemo",
            address: registry.address,
            explorer: `https://sepolia.basescan.org/address/${registry.address}`,
            deployer: deployer.address
        };
        
        console.log(`   ✅ Deployed at: ${registry.address}`);
        console.log(`   🔗 Explorer: https://sepolia.basescan.org/address/${registry.address}`);

        // 2. Deploy BoricuaSpeciesNFT
        console.log("\n🦜 Deploying BoricuaSpeciesNFT...");
        const BoricuaSpeciesNFT = await hre.ethers.getContractFactory("BoricuaSpeciesNFT");
        const nft = await BoricuaSpeciesNFT.deploy();
        await nft.deployed();
        
        deploymentResults.nft = {
            contract: "BoricuaSpeciesNFT",
            address: nft.address,
            explorer: `https://sepolia.basescan.org/address/${nft.address}`,
            deployer: deployer.address
        };
        
        console.log(`   ✅ Deployed at: ${nft.address}`);
        console.log(`   🔗 Explorer: https://sepolia.basescan.org/address/${nft.address}`);

        // 3. Deploy EcologyMiniDAO
        console.log("\n🗳️  Deploying EcologyMiniDAO...");
        const EcologyMiniDAO = await hre.ethers.getContractFactory("EcologyMiniDAO");
        const dao = await EcologyMiniDAO.deploy();
        await dao.deployed();
        
        deploymentResults.dao = {
            contract: "EcologyMiniDAO",
            address: dao.address,
            explorer: `https://sepolia.basescan.org/address/${dao.address}`,
            deployer: deployer.address
        };
        
        console.log(`   ✅ Deployed at: ${dao.address}`);
        console.log(`   🔗 Explorer: https://sepolia.basescan.org/address/${dao.address}`);

        // 4. Initialize with sample data
        console.log("\n📋 Initializing with Puerto Rico species data...");
        
        const speciesData = [
            {
                id: "tody",
                scientific: "Todus mexicanus",
                common: "Puerto Rican Tody",
                taino: "San Pedrito",
                habitat: "Mountain forests and coffee plantations",
                status: "Near Threatened",
                endemic: true,
                charismatic: true,
                rarity: 4
            },
            {
                id: "parrot",
                scientific: "Amazona vittata",
                common: "Puerto Rican Parrot",
                taino: "Iguaca Verde",
                habitat: "El Yunque rainforest",
                status: "Critically Endangered",
                endemic: true,
                charismatic: true,
                rarity: 5
            },
            {
                id: "coqui",
                scientific: "Eleutherodactylus coqui",
                common: "Common Coquí",
                taino: "Coquí",
                habitat: "Tropical forests and gardens",
                status: "Least Concern",
                endemic: true,
                charismatic: true,
                rarity: 2
            }
        ];

        for (const species of speciesData) {
            try {
                const tx = await registry.addSpecies(
                    species.id,
                    species.scientific,
                    species.common,
                    species.taino,
                    species.habitat,
                    species.status,
                    species.endemic,
                    species.charismatic,
                    species.rarity
                );
                await tx.wait();
                console.log(`   ✅ Added: ${species.scientific}`);
            } catch (error) {
                console.log(`   ⚠️  Error adding ${species.scientific}: ${error.message}`);
            }
        }

        // 5. Get deployment stats
        console.log("\n📊 Deployment Statistics:");
        try {
            const stats = await registry.getStats();
            const nftSupply = await nft.totalSupply();
            const daoStats = await dao.getStats();
            
            console.log(`   🌿 Registry - Species: ${stats[0]}, Endemic: ${stats[1]}`);
            console.log(`   🦜 NFT Collection - Total Supply: ${nftSupply}`);
            console.log(`   🗳️  DAO - Proposals: ${daoStats[0]}, Members: ${daoStats[1]}`);
        } catch (error) {
            console.log("   📊 Stats will be available once transactions confirm");
        }

        // 6. Save deployment results
        const timestamp = new Date().toISOString();
        const deploymentRecord = {
            network: hre.network.name,
            chainId: hre.network.config.chainId,
            timestamp,
            deployer: deployer.address,
            contracts: deploymentResults,
            gasUsed: "TBD", // Could track this
            status: "success"
        };

        const deploymentsDir = path.join(__dirname, "..", "..", "deployments");
        if (!fs.existsSync(deploymentsDir)) {
            fs.mkdirSync(deploymentsDir, { recursive: true });
        }

        const deploymentFile = path.join(deploymentsDir, `base-sepolia-${Date.now()}.json`);
        fs.writeFileSync(deploymentFile, JSON.stringify(deploymentRecord, null, 2));

        console.log("\n🎯 Portfolio Deployment Complete!");
        console.log("═".repeat(60));
        console.log("📋 Summary:");
        console.log(`   🌿 Registry: ${registry.address}`);
        console.log(`   🦜 NFT: ${nft.address}`);
        console.log(`   🗳️  DAO: ${dao.address}`);
        console.log(`   💾 Saved to: ${deploymentFile}`);
        
        console.log("\n🌟 Next Steps:");
        console.log("   1. Update README.md with contract addresses");
        console.log("   2. Add to portfolio with live demo links");
        console.log("   3. Test contract functions on Base Sepolia");
        console.log("   4. Consider contract verification");
        
        console.log("\n🔗 Portfolio Resources:");
        console.log("   📝 Base Sepolia Explorer: https://sepolia.basescan.org");
        console.log("   💰 Faucet: https://faucets.chain.link/base-sepolia");
        console.log("   🎯 Developer: haaz.eth");
        console.log("   🏢 Revenue: bakine.studio");

        return deploymentResults;

    } catch (error) {
        console.error("\n❌ Deployment Failed:");
        console.error(`   Error: ${error.message}`);
        
        if (error.message.includes("insufficient funds")) {
            console.error("   💡 Solution: Get more testnet ETH from Base Sepolia faucet");
        }
        
        throw error;
    }
}

if (require.main === module) {
    main()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error("❌ Deployment script failed:", error);
            process.exit(1);
        });
}

module.exports = main;