// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
require("@nomicfoundation/hardhat-toolbox");
const hre = require("hardhat");
require("hardhat-celo");

async function main() {

  const dealFactory = await hre.ethers.getContractFactory("DealContract");
  const deal = await dealFactory.deploy();

  await deal.deployed();

  console.log("Deal deployed to:", deal.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
