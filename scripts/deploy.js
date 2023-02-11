const hre = require("hardhat");
const {ethers} = require("hardhat");

let hhnr;
let hhm;
let hh;
let hhp;
let hhu;
let hhir;
let hho;
let gasUsed = 0;

async function main() {
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

  console.log(gasUsed.toString())

  console.log("Name Registry", hhnr.address)
  console.log("HexHeads", hh.address)
  console.log("HexHeads Prime", hhp.address)
  console.log("HexHeads Upgrade", hhu.address)
  console.log("Identicon Registry", hhir.address)
  console.log("Operator", hho.address)
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
