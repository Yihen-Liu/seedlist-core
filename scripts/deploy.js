// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile 
  // manually to make sure everything is compiled
  // await hre.run('compile');

/*
  const Strings = await hre.ethers.getContractFactory("Strings");
  const strings = await Strings.deploy();
  await strings.deployed();

  const KeySpace = await hre.ethers.getContractFactory("KeySpace",{
    libraries:{
      Strings: strings.address
    }
  });
*/
  const KeySpace = await hre.ethers.getContractFactory("KeySpace");
  const keyspace = await KeySpace.deploy("0xE93FffEAad5bDB6aE2D19E2528D419021ca32193");
  await keyspace.deployed();
  console.log("Keyspace deployed to:", keyspace.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
