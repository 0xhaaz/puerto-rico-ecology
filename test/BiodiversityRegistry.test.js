const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BiodiversityRegistryDemo", function () {
  let biodiversityRegistry;
  let owner, addr1, addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    
    const BiodiversityRegistry = await ethers.getContractFactory("BiodiversityRegistryDemo");
    biodiversityRegistry = await BiodiversityRegistry.deploy();
    await biodiversityRegistry.deployed();
  });

  describe("Deployment", function () {
    it("Should set the right maintainer", async function () {
      expect(await biodiversityRegistry.maintainer()).to.equal(owner.address);
    });

    it("Should set the right bakine studio address", async function () {
      expect(await biodiversityRegistry.bakineStudio()).to.equal(owner.address);
    });

    it("Should authorize the deployer as contributor", async function () {
      expect(await biodiversityRegistry.authorizedContributors(owner.address)).to.be.true;
    });
  });

  describe("Species Management", function () {
    it("Should add a species successfully", async function () {
      await biodiversityRegistry.addSpecies(
        "tody",
        "Todus mexicanus",
        "Puerto Rican Tody",
        "San Pedrito",
        "Mountain forests",
        "Near Threatened",
        true,
        true,
        4
      );

      const species = await biodiversityRegistry.getSpecies("tody");
      expect(species.scientificName).to.equal("Todus mexicanus");
      expect(species.isEndemic).to.be.true;
    });

    it("Should prevent unauthorized users from adding species", async function () {
      await expect(
        biodiversityRegistry.connect(addr1).addSpecies(
          "test",
          "Test species",
          "Test",
          "Taina",
          "Test habitat",
          "Test status",
          false,
          false,
          1
        )
      ).to.be.revertedWith("Not authorized");
    });

    it("Should track endemic species count correctly", async function () {
      await biodiversityRegistry.addSpecies(
        "endemic1",
        "Endemic species 1",
        "Common 1",
        "Taina 1",
        "Habitat 1",
        "Status 1",
        true,
        false,
        3
      );

      await biodiversityRegistry.addSpecies(
        "native1",
        "Native species 1", 
        "Common 2",
        "Taina 2",
        "Habitat 2",
        "Status 2",
        false,
        false,
        2
      );

      const stats = await biodiversityRegistry.getStats();
      expect(stats[1]).to.equal(1); // endemic count
    });
  });

  describe("Donations and Revenue", function () {
    it("Should accept donations and distribute correctly", async function () {
      const donationAmount = ethers.utils.parseEther("0.1");
      
      await expect(() =>
        biodiversityRegistry.connect(addr1).supportProject({ value: donationAmount })
      ).to.changeEtherBalances(
        [addr1, owner],
        [donationAmount.mul(-1), donationAmount.mul(70).div(100)]
      );
    });

    it("Should reject zero donations", async function () {
      await expect(
        biodiversityRegistry.connect(addr1).supportProject({ value: 0 })
      ).to.be.revertedWith("Donation must be positive");
    });
  });

  describe("Access Control", function () {
    it("Should allow maintainer to add contributors", async function () {
      await biodiversityRegistry.addContributor(addr1.address);
      expect(await biodiversityRegistry.authorizedContributors(addr1.address)).to.be.true;
    });

    it("Should prevent non-maintainer from adding contributors", async function () {
      await expect(
        biodiversityRegistry.connect(addr1).addContributor(addr2.address)
      ).to.be.revertedWith("Not authorized");
    });
  });

  describe("Query Functions", function () {
    beforeEach(async function () {
      // Add test species
      await biodiversityRegistry.addSpecies(
        "endemic1",
        "Endemic species 1",
        "Common 1", 
        "Taina 1",
        "Habitat 1",
        "Status 1",
        true,
        true,
        5
      );

      await biodiversityRegistry.addSpecies(
        "native1",
        "Native species 1",
        "Common 2",
        "Taina 2", 
        "Habitat 2",
        "Status 2",
        false,
        false,
        3
      );
    });

    it("Should return endemic species correctly", async function () {
      const endemicSpecies = await biodiversityRegistry.getEndemicSpecies();
      expect(endemicSpecies.length).to.equal(1);
      expect(endemicSpecies[0]).to.equal("endemic1");
    });

    it("Should return species by rarity", async function () {
      const rarity5Species = await biodiversityRegistry.getSpeciesByRarity(5);
      expect(rarity5Species.length).to.equal(1);
      expect(rarity5Species[0]).to.equal("endemic1");
    });

    it("Should return charismatic species", async function () {
      const charismaticSpecies = await biodiversityRegistry.getCharismaticSpecies();
      expect(charismaticSpecies.length).to.equal(1);
      expect(charismaticSpecies[0]).to.equal("endemic1");
    });
  });
});