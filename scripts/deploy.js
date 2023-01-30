const hre = require("hardhat");

async function main() {
  let hexHeads = await hre.ethers.getContractFactory("HexHeads");
  hexHeads = await hexHeads.deploy();
  await hexHeads.deployed();

  console.log("HexHeads contract is deployed to:", hexHeads.address)
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
