pragma solidity ^0.6.11;

import "liquity/Interfaces/ILQTYStaking.sol";

contract MockStaking is ILQTYStaking {
    function setAddresses
    (
        address _lqtyTokenAddress,
        address _lusdTokenAddress,
        address _troveManagerAddress,
        address _borrowerOperationsAddress,
        address _activePoolAddress
    ) public override {
        //noop
    }

    function stake(uint _LQTYamount) public override {
        //noop
    }

    function unstake(uint _LQTYamount) public override {
        //noop
    }

    function increaseF_ETH(uint _ETHFee) public override {
        //noop
    }

    function increaseF_LUSD(uint _LQTYFee) public override {
        //noop
    }

    function getPendingETHGain(address _user) public override view returns (uint) {
        //noop
        return 0;
    }

    function getPendingLUSDGain(address _user) public override view returns (uint) {
        //noop
        return 0;
    }
}