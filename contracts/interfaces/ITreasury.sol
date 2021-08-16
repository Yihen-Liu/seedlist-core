//SPDX-License-Identifier: MIT
pragma solidity >= 0.8.2;

interface ITreasury {
    function Mint(address verifier, address receiver) external returns(bool);
}
