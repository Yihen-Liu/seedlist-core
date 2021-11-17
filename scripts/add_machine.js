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

    const Registry = await hre.ethers.getContractFactory("Registry");
    let registry_addr = "0x74c5dc1bB65e1Dbc5a36C3ebF6863c53122b9592";
    const accounts = await hre.ethers.getSigners();
    const signer = accounts[0];
    const registry = new hre.ethers.Contract(registry_addr, Registry.interface, signer)

    let defaultMachine="0x6d89587672fb830A6B9Fb66E665528A38779e4c1";
    let transactionResponse = await registry.registryEncryptMachine("default", defaultMachine);
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





