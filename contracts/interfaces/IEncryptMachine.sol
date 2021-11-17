//SPDX-License-Identifier: MIT
pragma solidity >= 0.8.2;
interface IEncryptMachine {
    event InitKeySpace(address addr, bool res);
    event AddKey(string labelName, bool res);

    function initKeySpace(address addr, address addr0, bytes32 addrHash, bytes32 r, bytes32 s,uint8 v,uint256 randomNum) external returns(bool);
    function spaceExist(address addr, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v) external view returns(bool);
    function addKey(address keyspace, address addr, address addr0, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v, address id, address kid, string memory cryptoKey, string memory labelName) external returns(bool);
    function isLabelExist(address addr, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v, address labelId) external view returns(bool);
    function unstrictLabels(address addr, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v) external view returns(string[] memory);
    function getKey(address kid, address addr, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v) external view returns(string memory);
    function withdraw(address receiver, uint256 amount) external returns(bool);
}