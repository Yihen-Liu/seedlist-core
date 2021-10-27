const { ethers } = require("hardhat")
const fs = require("fs")
const hre = require("hardhat");

async function main() {
    const accounts = await hre.ethers.getSigners();
    const signer = accounts[0];

    const KeySpaceContract = await hre.ethers.getContractFactory("KeySpace");
    const keyspace_addr = "0xB2540E8906e0eb3C4aDD0F57264253757cb5B8e4";
    const keyspace = new hre.ethers.Contract(keyspace_addr, KeySpaceContract.interface, signer)

    let transactionResponse = await keyspace.setNetworkId(4);
    let receipt = await transactionResponse.wait(1);
    console.log("enable rinkeby network successed.");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
