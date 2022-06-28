// SPDX-License-Identifier: GPL3
pragma solidity ^0.6.11;

import "./IFeeDistributor.sol";
import "liquity/Dependencies/IERC20.sol";

contract FeeDistributor is IFeeDistributor {
    address public _borrowerOperations;
    IERC20 public _dai;

    uint256 public totalCollectedFees;
    uint256 public override collectedFees;
    mapping(address => uint256) public totalFeeShare;
    mapping(address => uint256) public withdrawnFees;

    address public _devWallet;
    address public _lendingPool;

    constructor(address borrowerOperations, IERC20 dai) public {
        _borrowerOperations = borrowerOperations;
        _dai = dai;
    }

    modifier onlyBorrowerOperations() {
        require(msg.sender == _borrowerOperations, "FD: Unauthorized caller");
        _;
    }

    function updateCollectedFees() external override onlyBorrowerOperations {
        uint256 currentFees = _dai.balanceOf(address(this));
    }

    function pushFees(uint256 amount) external override onlyBorrowerOperations {
        require(
            _dai.transferFrom(_borrowerOperations, address(this), amount),
            "FD: DAI transferFrom failure"
        );
        totalCollectedFees += amount;
    }

    function collectedFeesFor(address who) public override view returns (uint256) {
        // CASE 1: dev wallet
        if (who == _devWallet) {
            // 10% share
            return totalCollectedFees / 10;
        }
        // CASE 2: lending pool
        else if (who == _lendingPool) {
            // 90% share
            return totalCollectedFees * 10 / 9;
        }
        // CASE 3: anyone else
        else {
            return 0;
        }

    }

    function pullFees(uint256 amount) external override {
        return;
    }
}
