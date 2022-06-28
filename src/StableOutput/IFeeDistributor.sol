// SPDX-License-Identifier: GPL3
pragma solidity ^0.6.11;

interface IFeeDistributor {
    function collectedFees() external view returns (uint256);
    function pullFees(uint256 amount) external;
    function pushFees(uint256 amount) external;
    function updateCollectedFees() external;

    function collectedFeesFor(address) external view returns (uint256);
}
