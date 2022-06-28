pragma solidity ^0.6.11;

interface ILendingPool {
    function take(uint256 amount) external;

    function give(uint256 amount) external;

    function deposit(uint256 amount) external;

    function withdraw(uint256 amount) external;
}
