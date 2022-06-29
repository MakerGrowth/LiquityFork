pragma solidity ^0.6.11;

import "liquity/Interfaces/IPriceFeed.sol";

contract MockPriceFeed is IPriceFeed {
    uint256 private price;

    function setPrice(uint256 _price) public {
        price = _price;
    }

    function fetchPrice() public override returns (uint256) {
        return price;
    }

    function getPrice() public view returns (uint256) {
        return price;
    }
}