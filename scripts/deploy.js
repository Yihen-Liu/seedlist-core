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
  const treasury_addr = "0x06a9986cdb99642B776cA6C772932d6f7ec5cb94";
  const mask_addr = "0x96EAE123Ea4439D443042bD8699DE32a5940Ad5D";
  const seeder_addr = "0xa32a90C856Fa523f83bEEB281f2Eb04EEB724225";
  const DefaultEncrypt = await hre.ethers.getContractFactory("DefaultEncrypt");
  const encrypt = await DefaultEncrypt.deploy(treasury_addr, mask_addr, seeder_addr);
  await encrypt.deployed();
  console.log("DefaultEncrypt deployed to:", encrypt.address);


  const accounts = await hre.ethers.getSigners();
  const signer = accounts[0];
  const de = new hre.ethers.Contract(encrypt.address, DefaultEncrypt.interface, signer)

  let transactionResponse = await de.setNetworkId(4);
  let receipt = await transactionResponse.wait(1)
  console.log("enable rinkeby network finished");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
