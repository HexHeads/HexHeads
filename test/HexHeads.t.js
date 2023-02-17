const { ethers } = require("hardhat");
const { solidity } = require("ethereum-waffle");
const chai = require("chai");
chai.use(solidity);
const { expect } = require("chai");

function addressToId(address) {
  return BigInt(address).toString()
}

function checkMetadata(encoded, name, id, level, dbg=false) {
  const metadata = JSON.parse(new Buffer.from(encoded.slice(29), 'base64').toString('ascii'));
  const correct = metadata.name === name &&
         metadata.image === `https://raw.githubusercontent.com/k0rean-rand0m/img/main/question.png` &&
         metadata.attributes[0].value === name

  if (dbg) console.log(metadata, correct)
  return correct
}

describe("HexHeads", function () {

  let hhnr;
  let hhm;
  let hh;
  let hhp;
  let hhu;
  let hhir;
  let hho;
  let signers;
  const addresses = [];

  before(async function () {

    let gasUsed = 0;

    signers = await ethers.getSigners();
    for (const i in signers) addresses.push(signers[i].address.toLowerCase());

    const HHNR = await ethers.getContractFactory("NameRegistry");
    hhnr = await HHNR.deploy();
    await hhnr.deployed();
    gasUsed = hhnr.deployTransaction.gasLimit.add(gasUsed)

    const HHM = await ethers.getContractFactory("UnrevealedMetadata");
    hhm = await HHM.deploy(hhnr.address);
    await hhm.deployed();
    gasUsed = hhm.deployTransaction.gasLimit.add(gasUsed)

    const HH = await ethers.getContractFactory("HexHeads");
    hh = await HH.deploy(hhm.address);
    await hh.deployed();
    gasUsed = hh.deployTransaction.gasLimit.add(gasUsed)

    const HHP = await ethers.getContractFactory("HexHeadsPrime");
    hhp = await HHP.deploy(hhm.address);
    await hhp.deployed();
    gasUsed = hhp.deployTransaction.gasLimit.add(gasUsed)

    const HHU = await ethers.getContractFactory("HexHeadsUpgrade");
    hhu = await HHU.deploy("0xafc0916167A342a002dB232ec25fC7Bc372771b3");
    await hhu.deployed();
    gasUsed = hhu.deployTransaction.gasLimit.add(gasUsed)

    const HHIR = await ethers.getContractFactory("IdenticonRegistry");
    hhir = await HHIR.deploy();
    await hhir.deployed();
    gasUsed = hhir.deployTransaction.gasLimit.add(gasUsed)

    const HHO = await ethers.getContractFactory("HexHeadsOperator");
    hho = await HHO.deploy(
        hh.address,
        hhp.address,
        hhu.address,
        hhnr.address,
        hhir.address
    );
    await hho.deployed();
    gasUsed = hho.deployTransaction.gasLimit.add(gasUsed)

    await (await hhnr.setOperator(hho.address)).wait()
    await (await hh.setOperator(hho.address)).wait()
    await (await hhp.setOperator(hho.address)).wait()
    await (await hhu.setOperator(hho.address)).wait()
    await (await hhir.setOperator(hho.address)).wait()

    console.log("Gas used", gasUsed.toString())
    console.log("Name Registry", hhnr.address)
    console.log("HexHeads", hh.address)
    console.log("HexHeads Prime", hhp.address)
    console.log("HexHeads Upgrade", hhu.address)
    console.log("Identicon Registry", hhir.address)
    console.log("Operator", hho.address)
  })

  describe("Main tests", function () {
    // it("Should metadata", async function () {
    //   console.log(await hhm2._addressToTraits("0xA105440e9B0C5A5420954746A9d98c9F7C6580F8"))
    // })

    it("Operator: Should check HexHeads claim", async function () {
      await(await hho.mint("0x0")).wait();
      expect ((await hh.ownerOf(addressToId(addresses[0]))).toLowerCase()).to.equal(addresses[0])

      await expect(hho.connect(signers[1]).mint("0x0")).to.be.revertedWith("NAME_IS_ALREADY_CLAIMED")

      await hho.connect(signers[1]).mint("0x1");
      expect ((await hh.ownerOf(addressToId(addresses[1]))).toLowerCase()).to.equal(addresses[1]);

      await expect(hho.connect(signers[1]).mint("0x2")).to.be.revertedWith("ALREADY_MINTED");
    });

    it("HexHeads: Should check HexHeads metadata", async function () {
      let uri = await hh.tokenURI(addressToId(addresses[0]));
      expect(checkMetadata(uri, "0x0", addressToId(addresses[0]), 0)).to.be.true;

      uri = await hh.tokenURI(addressToId(addresses[1]));
      expect(checkMetadata(uri, "0x1", addressToId(addresses[1]), 0)).to.be.true;

      // Non-minted tokens
      uri = await hh.tokenURI(addressToId(addresses[2]));
      expect(checkMetadata(uri, "HexHead", addressToId(addresses[2]), 0)).to.be.true;

      uri = await hhp.tokenURI(addressToId(addresses[0]));
      expect(checkMetadata(uri, "0x0", addressToId(addresses[0]), 0)).to.be.true;
    });

    it("Operator: Should check renaming", async function () {
      await expect(hho.rename(addresses[0], "0x1")).to.be.revertedWith("NAME_IS_ALREADY_CLAIMED");
      await (await (hho.rename(addresses[0], "0x2"))).wait();
      let uri = await hhp.tokenURI(addresses[0]);
      expect(checkMetadata(uri, "0x2", addresses[0], 0)).to.be.true;
    });

    it("Should check Upgrades mint", async function () {
      const priceStep = await hhu.priceStep();

      // Mint by Owner
      let price = await hhu.price();
      await (await hhu.mint(addresses[0], 2)).wait();
      expect(await hhu.price()).to.equal(price);
      expect(await hhu.balanceOf(addresses[0], 1)).to.equal(2);

      price = await hhu.price();
      await (await hhu.connect(signers[1]).mint(addresses[1], 3, {value: price.mul(3)})).wait();
      expect(await hhu.balanceOf(addresses[1], 1)).to.equal(3);
      expect(await hhu.price()).to.equal(price.add(priceStep));

      await expect(hhu.connect(signers[1]).mint(addresses[1], 1, {value: price})).to.be.revertedWith("INSUFFICIENT_ETH");
    });

    it("Should check Upgrades", async function () {
      await(await hho.upgrade(addresses[0], 2)).wait();
      expect(await hhu.balanceOf(addresses[0], 1)).to.equal(0);
      expect(await hh.balanceOf(addresses[0])).to.equal(0);
      expect(await hhp.balanceOf(addresses[0])).to.equal(1);
    });

  });
});
