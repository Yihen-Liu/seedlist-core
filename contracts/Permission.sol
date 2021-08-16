// SPDX-License-Identifier: MIT
pragma solidity>=0.8.2;

contract Permission {
    address public owner;
    bool public addable = true;
    bool public updateable = true;
    bool public mintable = false;
    uint public networkID = 1;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier forbidden(string memory s) {
        revert(s);
        _;
    }

    modifier network() {
        uint chainId;
        assembly {
            chainId := chainid()
        }
        require(chainId==networkID);
       _;
    }

    modifier canAdd() {
        require(addable == true);
        _;
    }

    modifier canUpdate() {
        require(updateable == true);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function setAddable(bool _addable) onlyOwner public returns(bool){
        addable = _addable;
        return true;
    }

    function setUpdateable(bool _updateadd) onlyOwner public returns(bool){
        updateable = _updateadd;
        return true;
    }

    function transferOwnership(address _owner) onlyOwner public {
        require(_owner != address(0));
        owner = _owner;

        emit OwnershipTransferred(owner, _owner);
    }

    function setMintable(bool value) onlyOwner external returns(bool){
            mintable = value;
        return true;
    }

    function setNetworkId(uint _networkID) external returns(bool){
        networkID = _networkID;
        return true;
    }
}
