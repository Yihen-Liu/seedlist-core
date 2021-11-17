//SPDX-License-Identifier: MIT
pragma solidity >= 0.8.2;
import "./interfaces/IRegistry.sol";
contract Registry is IRegistry{
    mapping(string=>address) encryMachine;
    mapping(address=>bool) hasRegister;
    constructor() {

    }

    function registryEncryptMachine(string memory version, address machine) override external returns(bool){
        require(bytes(version).length>0 && machine!=address(0x0), "registry params error");
        require(encryMachine[version]==address(0x0) && hasRegister[machine]==false, "encrypt machine has exists");
        //判断 machine 实现了 IEncryptMachine接口
        encryMachine[version] = machine;
        hasRegister[machine] = true;
        return true;
    }

    function versionHasRegister(string memory version)override external view returns(bool){
        require(bytes(version).length>0, "version is null");
        return encryMachine[version]!=address(0x0);
    }

    function machineHasRegister(address machine)override external view returns(bool){
        require(machine!=address(0x0)," machine address is null");
        return hasRegister[machine];
    }
}
