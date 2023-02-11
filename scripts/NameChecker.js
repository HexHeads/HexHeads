const hre = require("hardhat");
const {ethers} = require("hardhat");

async function main() {
  const HHNR = await ethers.getContractFactory("NameRegistry");
  const hhnr = await HHNR.attach("0x13a2E06829238477134726003102C09A97A0EDeE");
  console.log(await hhnr.claimed("SUFUR"));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
