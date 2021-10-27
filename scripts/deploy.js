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
  const treasury_addr = "0xB5fbCCADaE04DA1f580f0430708A0D56693Cb015";
  const mask_addr = "0xCA9cCb0305Cea7Fb2ca076FE282606376C05DfBF";
  const KeySpace = await hre.ethers.getContractFactory("KeySpace");
  const keyspace = await KeySpace.deploy(treasury_addr, mask_addr);
  await keyspace.deployed();
  console.log("Keyspace deployed to:", keyspace.address);


    const accounts = await hre.ethers.getSigners();
    const signer = accounts[0];
    const ks = new hre.ethers.Contract(keyspace.address, KeySpace.interface, signer)

    let transactionResponse = await ks.setNetworkId(4);
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
