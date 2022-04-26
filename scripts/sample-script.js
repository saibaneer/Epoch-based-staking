// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

let alice;
let bob;
let charlie;
let tokens;
let bank;

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
   [alice, bob, charlie] = await ethers.getSigners();
   const Tokens = await ethers.getContractFactory("XYZ", charlie);
   tokens = await Tokens.deploy(1000000000000);
   await tokens.deployed();

   const Bank = await ethers.getContractFactory("BankV2", charlie);
   bank = await Bank.deploy(tokens.address, 1, 10000);
   await bank.deployed();

   await tokens.connect(charlie).approve(tokens.address, 100000);   
   await tokens.connect(charlie).transfer(tokens.address, 100000);

  console.log("Bank is deployed to:", bank.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
