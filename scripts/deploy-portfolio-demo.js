const hre = require("hardhat");

async function main() {
    console.log("🚀 Deploying Portfolio Demo to Base Sepolia...");
    console.log("🎯 Created by: haaz.eth");
    console.log("🏢 Revenue flows to: bakine.studio\n");

    const [deployer] = await hre.ethers.getSigners();
    console.log("📝 Deploying with account:", deployer.address);
    console.log("💰 Account balance:", hre.ethers.utils.formatEther(await deployer.getBalance()), "ETH\n");

    // Deploy Registry
    console.log("🌿 Deploying BiodiversityRegistryDemo...");
    const BiodiversityRegistry = await hre.ethers.getContractFactory("BiodiversityRegistryDemo");
    const registry = await BiodiversityRegistry.deploy();
    await registry.deployed();
    console.log("✅ BiodiversityRegistry deployed to:", registry.address);

    // Deploy NFT Collection
    console.log("🦜 Deploying BoricuaSpeciesNFT...");
    const BoricuaSpeciesNFT = await hre.ethers.getContractFactory("BoricuaSpeciesNFT");
    const nft = await BoricuaSpeciesNFT.deploy();
    await nft.deployed();
    console.log("✅ BoricuaSpeciesNFT deployed to:", nft.address);

    // Deploy Mini DAO
    console.log("🗳️  Deploying EcologyMiniDAO...");
    const EcologyMiniDAO = await hre.ethers.getContractFactory("EcologyMiniDAO");
    const dao = await EcologyMiniDAO.deploy();
    await dao.deployed();
    console.log("✅ EcologyMiniDAO deployed to:", dao.address);

    console.log("\n📋 Adding initial species data...");

    try {
        // Add Puerto Rican Tody (Endemic)
        await registry.addSpecies(
            "tody",
            "Todus mexicanus", 
            "Puerto Rican Tody",
            "San Pedrito",
            "Mountain forests and coffee plantations",
            "Near Threatened",
            true,  // endemic
            true,  // charismatic
            4      // rarity
        );
        console.log("✅ Added: Puerto Rican Tody (Endemic)");

        // Add Iguaca (Native)
        await registry.addSpecies(
            "iguaca",
            "Dendrocygna arborea",
            "West Indian Whistling Duck", 
            "Iguaca",
            "Mangroves and coastal wetlands",
            "Vulnerable",
            false, // not endemic to PR
            true,  // charismatic
            5      // rarity
        );
        console.log("✅ Added: Iguaca (Native Whistling Duck)");

        // Add Puerto Rican Parrot (Endemic)
        await registry.addSpecies(
            "parrot",
            "Amazona vittata",
            "Puerto Rican Parrot",
            "Iguaca",
            "El Yunque rainforest",
            "Critically Endangered", 
            true,  // endemic
            true,  // charismatic
            5      // rarity
        );
        console.log("✅ Added: Puerto Rican Parrot (Endemic)");

        // Add Elfin Woods Warbler (Endemic)
        await registry.addSpecies(
            "warbler",
            "Setophaga angelae",
            "Elfin Woods Warbler",
            "Reinita de Bosque Enano",
            "Elfin woodland forests",
            "Vulnerable",
            true,  // endemic
            false, // not charismatic (small songbird)
            3      // rarity
        );
        console.log("✅ Added: Elfin Woods Warbler (Endemic)");

        // Add Coquí Common (Endemic)
        await registry.addSpecies(
            "coqui",
            "Eleutherodactylus coqui",
            "Common Coquí",
            "Coquí",
            "Tropical forests and gardens",
            "Least Concern",
            true,  // endemic
            true,  // charismatic (cultural icon)
            2      // rarity
        );
        console.log("✅ Added: Common Coquí (Endemic)");

    } catch (error) {
        console.log("⚠️  Error adding species:", error.message);
    }

    console.log("\n🎯 Portfolio Demo Deployed Successfully!");
    console.log("\n📊 Contract Summary:");
    console.log("═".repeat(50));
    console.log("🌿 Biodiversity Registry:", registry.address);
    console.log("🦜 Species NFT Collection:", nft.address);
    console.log("🗳️  Mini DAO:", dao.address);
    console.log("═".repeat(50));

    console.log("\n🔗 View on Base Sepolia Explorer:");
    console.log(`Registry: https://sepolia.basescan.org/address/${registry.address}`);
    console.log(`NFT: https://sepolia.basescan.org/address/${nft.address}`);
    console.log(`DAO: https://sepolia.basescan.org/address/${dao.address}`);

    console.log("\n📋 Portfolio Documentation:");
    console.log("═".repeat(50));
    console.log("🎯 Project: Biodiversity DAO & NFT System");
    console.log("👨‍💻 Developer: haaz.eth");
    console.log("🏢 Revenue Model: 70% creator, 30% bakine.studio");
    console.log("🌟 Skills Demonstrated:");
    console.log("   • Smart contract development & deployment");
    console.log("   • Data management and storage optimization");
    console.log("   • NFT metadata generation and SVG creation");
    console.log("   • DAO governance and voting mechanisms");
    console.log("   • Payment distribution and revenue systems");
    console.log("   • Access control and permission management");
    console.log("═".repeat(50));

    console.log("\n🚀 Next Steps:");
    console.log("1. Test contract functions on Base Sepolia");
    console.log("2. Add to portfolio with contract addresses");
    console.log("3. Consider mainnet deployment when ready");
    console.log("4. Integrate with ecology game development");

    // Get some stats
    try {
        const speciesCount = await registry.getSpeciesCount();
        const stats = await registry.getStats();
        console.log("\n📈 Initial Registry Stats:");
        console.log(`   • Total Species: ${speciesCount}`);
        console.log(`   • Endemic Species: ${stats[1]}`);
        console.log(`   • Total Donations: ${hre.ethers.utils.formatEther(stats[2])} ETH`);
    } catch (error) {
        console.log("📊 Stats will be available once transactions confirm");
    }

    console.log("\n🎉 Deployment Complete! Ready for portfolio showcase.");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ Deployment failed:", error);
        process.exit(1);
    });