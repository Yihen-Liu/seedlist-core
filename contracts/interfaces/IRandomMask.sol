//SPDX-License-Identifier: MIT
pragma solidity >= 0.8.2;
interface IRandomMask {
    function mintRandomMask(bytes32 requestId, uint256 randomNum) external;
}
