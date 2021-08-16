// SPDX-License-Identifier: MIT
pragma solidity=0.8.2;

library  Verifier {
    function recoverAddr(bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
        return ecrecover(msgHash, v, r, s);
    }

    function isSigned(address addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {
        return ecrecover(msgHash, v, r, s) == addr;
    }
}
