// SPDX-License-Identifier: GPL3
pragma solidity ^0.6.11;

interface IFeeCollector {
    function pullFees(uint256 amount) external;

}
