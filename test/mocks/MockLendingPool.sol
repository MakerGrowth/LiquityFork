pragma solidity ^0.6.11;

import "src/StableInput/ILendingPool.sol";
import "liquity/Dependencies/IERC20.sol";

contract MockLendingPool is ILendingPool {
    IERC20 public token;
    constructor(IERC20 _token) public {
        token = _token;
    }

    function take(uint amount) public override {
        token.transfer(msg.sender, amount);
    }

    function give(uint amount) public override {
        token.transferFrom(msg.sender, address(this), amount);
    }

    function deposit(uint amount) public override {
        //noop
    }

    function withdraw(uint amount) public override {
        //noop
    }
}