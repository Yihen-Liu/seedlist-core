// SPDX-License-Identifier: MIT
pragma solidity>=0.8.2;

import "./Permission.sol";
import "./Config.sol";
import "./interfaces/ITreasury.sol";
import "./interfaces/IKeySpace.sol";
import "./interfaces/IRandomMask.sol";
import "hardhat/console.sol";

contract KeySpace is Permission, Config, IKeySpace{
    struct Key{
        string value;
        uint startTime;
        uint updateTime;
        string contractVersion;
    }
    struct SpaceValue{
        uint startTime;
        uint updateTime;
        string contractVersion;
    }

    address public treasury;
    address public mask;
    mapping(address=>Key) public keys;
    mapping(address=>mapping(address=>bool)) public labelExist;
    mapping(address=>string[]) public labels;

    mapping (address => SpaceValue) public keySpace;
    mapping(address=>bool) public keySpaceExist;

    constructor(address _treasury, address _mask) {
        owner = msg.sender;
        treasury = _treasury;
        mask = _mask;
    }

    function setTreasury(address addr) onlyOwner external returns(bool){
        require(addr!=address(0), "setTreasury: addr is ZERO");
        treasury = addr;
        return true;
    }

    function setMask(address addr) onlyOwner external returns(bool){
        require(addr!=address(0), "setMask: addr is ZERO");
        mask = addr;
        return true;
    }

    function initKeySpace(address addr, address addr0, bytes32 addrHash, bytes32 r, bytes32 s,uint8 v, uint256 randomNum, string memory _version) network canAdd override public returns(bool){
        //todo: use balance to calculate "addr" replaced, address(msg.sender).balance
        require(ecrecover(addrHash, v, r, s) == addr0,"initSpace: Verify signature ERROR");
        require(addr != address(0),"Addr is ZERO");
        require(keySpaceExist[addr]==false,"Keyspace has Exist");
        if(keySpaceExist[addr]==true){
            emit InitKeySpace(addr, _version, false);
            revert("Keyspace has exist");
        }

        keySpace[addr] = SpaceValue(
            {startTime:block.timestamp, updateTime:block.timestamp,
            contractVersion:_version}
        );
        keySpaceExist[addr] = true;
        emit InitKeySpace(addr, _version, true);

        if(nftMintable==true){
            IRandomMask(mask).mintRandomMask(addrHash, randomNum);
        }
        return true;
    }

    function spaceExist(address addr, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v) network external override view returns(bool){
        require(addr != address(0), "Addr is ZERO");
        require(ecrecover(addrHash, v, r, s) == addr,"spaceExist: Verify signature ERROR");
        return keySpaceExist[addr];
    }

    function addKey(address keyspace, address addr, address addr0, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v, address id, string memory cryptoKey, string memory labelName, string memory _version) network canAdd override external returns(bool){
        require(addr!=address(0), "Addr is ZERO");
        require(keyspace!=address(0), "Keyspace is ZERO");
        require(keySpaceExist[addr]==true, "Keyspace Not Exist");
        require(ecrecover(addrHash, v, r,s)==addr0, "Verify signature ERROR");
        require(bytes(cryptoKey).length<=MAX_CRYPTO_KEY_LEN, "Crypto Key Length > 2048");
        if(labelExist[addr][id] == true){
            emit AddKey(labelName, false);
            revert("Label has exist");
        }

        keys[id] = Key({value:cryptoKey, startTime:block.timestamp, updateTime:block.timestamp, contractVersion:_version});
        labelExist[addr][id] = true;
        labels[keyspace].push(labelName);
        emit AddKey(labelName, true);

        if(tokenMintable == true) {
            ITreasury(treasury).Mint(address(0), msg.sender);
        }

        return true;
    }

    function isLabelExist(address addr, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v, address labelId) network external override view returns(bool) {
        require(addr!=address(0), "Addr is ZERO");
        require(labelId!=address(0), "Label is ZERO");
        require(ecrecover(addrHash, v, r,s)==addr, "labelExist: Verify signature ERROR");
        return labelExist[addr][labelId];
    }

    function updateKey(address addr, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v, address label, address labelId, string memory cryptoKey) network canUpdate public returns(bool){
        require(addr!=address(0), "Addr is ZERO");
        require(ecrecover(addrHash, v, r,s)==addr, "Verify signature ERROR");
        require(labelExist[addr][labelId]==true, "Label NO Exist");
        require(bytes(cryptoKey).length<=MAX_CRYPTO_KEY_LEN);

        keys[label].value=cryptoKey;
        keys[label].updateTime = block.timestamp;
        return true;
    }

    function unstrictLabels(address addr, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v)network override external view returns(string[] memory){
        require(addr!=address(0), "Addr is ZERO");
        require(ecrecover(addrHash, v, r,s)==addr, "unstrict labels: Verify signature ERROR");
        return labels[addr];
    }

    function getKey(address id, address addr, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v)network override external view returns(string memory){
        require(id!=address(0), "id is ZERO");
        require(addr!=address(0), "Addr is ZERO");
        require(ecrecover(addrHash, v, r,s)==addr, "getKey: Verify signature ERROR");
        return keys[id].value;
    }

    function selfdestruct() forbidden("Forbidden:selfdestruct") network external view returns(bool) {
        return true;
    }
}