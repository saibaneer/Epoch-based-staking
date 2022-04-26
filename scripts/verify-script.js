//import console from "console";
const hre = require("hardhat");


const address = "0x2828F385abB834af15DA309060Dd98bF040215Ca";
const epoch_period = 1;
const reward_pool_size = "100000";

async function main() {
  await hre.run("verify:verify", {
    address: "0xa7617F007e68Ccb57b19ae75521c48b87d85e355",
    constructorArguments: [address, epoch_period, reward_pool_size],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
