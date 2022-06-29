pragma solidity ^0.6.11;

import {ERC20 as OZERC20} from "openzeppelin/token/ERC20/ERC20.sol";

contract MockToken is OZERC20("MOCK TOKEN", "MOT"){
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}