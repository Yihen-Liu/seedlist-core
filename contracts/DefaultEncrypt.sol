// SPDX-License-Identifier: MIT
pragma solidity>=0.8.2;

import "./Permission.sol";
import "./Config.sol";
import "./interfaces/ITreasury.sol";
import "./interfaces/IEncryptMachine.sol";
import "./interfaces/IRandomMask.sol";
import "./interfaces/IERC20.sol";

contract DefaultEncrypt is Permission, Config, IEncryptMachine{
    struct Key{
        string value;
        uint startTime;
        uint updateTime;
    }
    struct SpaceValue{
        uint startTime;
        uint updateTime;
    }

    mapping(address=>string) encryptText;
    address public treasury;
    address public mask;
    address public seedToken;
    mapping(address=>Key) public keys;
    mapping(address=>mapping(address=>bool)) public labelExist;
    mapping(address=>string[]) public labels;

    mapping (address => SpaceValue) public keySpace;
    mapping(address=>bool) public keySpaceExist;

    constructor(address _treasury, address _mask, address _seedToken) {
        owner = msg.sender;
        treasury = _treasury;
        mask = _mask;
        seedToken = _seedToken;
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

    function initKeySpace(address addr, address addr0, bytes32 addrHash, bytes32 r, bytes32 s,uint8 v, uint256 randomNum) network canAdd override public returns(bool){
        require(ecrecover(addrHash, v, r, s) == addr0,"initSpace: Verify signature ERROR");
        require(addr != address(0),"Addr is ZERO");
        require(keySpaceExist[addr]==false,"Keyspace has Exist");
        if(keySpaceExist[addr]==true){
            emit InitKeySpace(addr, false);
            revert("Keyspace has exist");
        }

        keySpace[addr] = SpaceValue( {startTime:block.timestamp, updateTime:block.timestamp}
        );
        keySpaceExist[addr] = true;
        emit InitKeySpace(addr, true);

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

    function addKey(address keyspace, address addr, address addr0, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v, address id, address kid, string memory cryptoKey, string memory labelName) network canAdd override external returns(bool){
        require(addr!=address(0), "Addr is ZERO");
        require(keyspace!=address(0), "Keyspace is ZERO");
        require(keySpaceExist[addr]==true, "Keyspace Not Exist");
        require(ecrecover(addrHash, v, r,s)==addr0, "Verify signature ERROR");
        require(bytes(cryptoKey).length<=MAX_CRYPTO_KEY_LEN, "Crypto Key Length > 2048");
        if(labelExist[addr][id] == true){
            emit AddKey(labelName, false);
            revert("Label has exist");
        }

        keys[kid] = Key({value:cryptoKey, startTime:block.timestamp, updateTime:block.timestamp});
        labelExist[addr][id] = true;
        labels[keyspace].push(labelName);
        emit AddKey(labelName, true);

        if(tokenMintable == true) {
            //receiver = receiver==address(0) ? msg.sender : receiver;
            ITreasury(treasury).Mint(address(0), msg.sender);
        }

        return true;
    }

    function substring(string memory str, uint startIndex, uint endIndex) internal pure returns (string memory) {
        require(endIndex>startIndex,"end > start");
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
    }

    function addSplitKey(address keyspace, address addr, address addr0, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v, address id, address kid0,address kid1, string memory cryptoKey, string memory labelName) network canAdd external {
        require(addr!=address(0), "Addr is ZERO");
        require(keyspace!=address(0), "Keyspace is ZERO");
        require(keySpaceExist[addr]==true, "Keyspace Not Exist");
        require(ecrecover(addrHash, v, r,s)==addr0, "Verify signature ERROR");
        uint textlen = bytes(cryptoKey).length;
        require(textlen<=MAX_CRYPTO_KEY_LEN, "Crypto Key Length > 2048");
        if(labelExist[addr][id] == true){
            emit AddKey(labelName, false);
            revert("Label has exist");
        }

        //keys[kid] = Key({value:cryptoKey, startTime:block.timestamp, updateTime:block.timestamp});
        encryptText[kid0] = substring(cryptoKey,0,textlen/2);
        encryptText[kid1] = substring(cryptoKey,textlen/2,textlen);
        labelExist[addr][id] = true;
        labels[keyspace].push(labelName);
        emit AddKey(labelName, true);

        if(tokenMintable == true) {
            //receiver = receiver==address(0) ? msg.sender : receiver;
            ITreasury(treasury).Mint(address(0), msg.sender);
        }

        //return true;
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
        require(ecrecover(addrHash, v, r, s)==addr, "unstrict labels: Verify signature ERROR");
        return labels[addr];
    }

    function getKey(address id, address addr, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v) override external view returns(string memory){
        require(id!=address(0), "id is ZERO");
        require(addr!=address(0), "Addr is ZERO");
        require(ecrecover(addrHash, v, r,s)==addr, "getKey: Verify signature ERROR");
        return keys[id].value;
    }

    function getSplitKey(address addr, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v, address kid0, address kid1) external view returns(string memory, string memory){
        require(addr!=address(0), "Addr is ZERO");
        require(ecrecover(addrHash, v, r,s)==addr, "getKey: Verify signature ERROR");
        return (encryptText[kid0], encryptText[kid1]);
    }

    function withdraw(address receiver, uint256 amount) override external onlyOwner returns(bool){
        return IERC20(seedToken).transfer(receiver, amount);
    }
}