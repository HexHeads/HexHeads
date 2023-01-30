const { ethers } = require("hardhat");
const { solidity } = require("ethereum-waffle");
const chai = require("chai");
chai.use(solidity);
const { expect } = require("chai");

function idToAddress(id) {
  return "0x"+BigInt(id).toString(16).padStart(40, "0").toLowerCase()
}

function addressToId(address) {
  return BigInt(address).toString()
}

function checkMetadata(encoded, name, id, level) {
  // console.log()
  const metadata = JSON.parse(new Buffer.from(encoded.slice(29), 'base64').toString('ascii'));
  return metadata.name === name &&
         metadata.image === `https://hexheads.xyz/generator?id=${id}` &&
         metadata.attributes[0].value === name &&
         metadata.attributes[1].value === level.toString();
}

describe("HexHeads", function () {

  let hh;
  let hhm;
  let hhnr;
  let signers;
  const addresses = [];

  before(async function () {
    // Deploying NameRegistry
    const HHNR = await ethers.getContractFactory("NameRegistry");
    hhnr = await HHNR.deploy();
    await hhnr.deployed();

    const HHM = await ethers.getContractFactory("UnrevealedMetadata");
    hhm = await HHM.deploy(hhnr.address);
    await hhm.deployed();

    const HH = await ethers.getContractFactory("HexHeads");
    hh = await HH.deploy(hhnr.address, hhm.address, "0xC00eD8a8533BD247483Ff8A6Ce02467Ba1faa372");
    await hh.deployed();

    await (await hhnr.setHexHeads(hh.address)).wait();

    signers = await ethers.getSigners();
    for (const i in signers) addresses.push(signers[i].address.toLowerCase());
  })

  describe("Deployment", function () {

    it("Should check claim", async function () {
      await(await hh.mint(0, "0x0")).wait();

      expect(await hh.balanceOf(addresses[0])).to.equal(1);
      expect((await hh.ownerOf(addressToId(addresses[0]))).toLowerCase()).to.equal(addresses[0]);
      expect(await hhnr.name(addressToId(addresses[0]))).to.equal("0x0");
      let metadata = await hh.tokenURI(addressToId(addresses[0]));
      expect(checkMetadata(metadata, "0x0", addressToId(addresses[0]), 0)).to.equal(true);

      await(await hh.connect(signers[1]).mint(0, "0x1")).wait();
      expect(await hh.balanceOf(addresses[1])).to.equal(1);
      expect((await hh.ownerOf(addressToId(addresses[1]))).toLowerCase()).to.equal(addresses[1]);
      expect(await hhnr.name(addressToId(addresses[1]))).to.equal("0x1");
      metadata = await hh.tokenURI(addressToId(addresses[1]));
      expect(checkMetadata(metadata, "0x1", addressToId(addresses[1]), 0)).to.equal(true);
    });

    it("Should check mint", async function () {
      let price = await hh.primeLevelPrice();
      await(await hh.connect(signers[2]).mint(2, "0x2", {value: price.mul(2)})).wait();
      expect(await hh.balanceOf(addresses[2])).to.equal(1);
      expect((await hh.ownerOf(addressToId(addresses[2]))).toLowerCase()).to.equal(addresses[2]);
      expect(await hhnr.name(addressToId(addresses[2]))).to.equal("0x2");
      let metadata = await hh.tokenURI(addressToId(addresses[2]));
      expect(checkMetadata(metadata, "0x2", addressToId(addresses[2]), 2)).to.equal(true);
    });

    it("Should check namings", async function () {
      await hhnr.rename(addressToId(addresses[0]), "0x99");
      let metadata = await hh.tokenURI(addressToId(addresses[0]));
      expect(checkMetadata(metadata, "0x99", addressToId(addresses[0]), 0)).to.equal(true);

      await expect(hhnr.rename(addresses[1], "0x9")).to.be.revertedWith("NOT_THE_OWNER_OF_HEXHEAD");
      await expect(hhnr.rename(addresses[0], "0x1")).to.be.revertedWith("NAME_IS_ALREADY_CLAIMED");
      await expect(hhnr.rename(addresses[0], "HexHead")).to.be.revertedWith("NAME_IS_NOT_AVAILABLE");
    })

  });
});
