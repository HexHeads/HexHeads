const hre = require("hardhat");
const {ethers} = require("hardhat");

async function main() {
  const HH = await ethers.getContractFactory("HexHeads");
  const hh = await HH.attach("0xEC5B3bD893F5091DFC113d95165e55367Db6aada");
  console.log(await hh.tokenURI(2));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
