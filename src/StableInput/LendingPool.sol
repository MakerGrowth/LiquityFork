pragma solidity ^0.6.11;

import "./PoolDepositVoucher.sol";

contract LendingPool {
    PoolDepositVoucher public voucherToken;
    IERC20 public baseToken;
    uint256 public baseTokenBalance;
    address public borrowerOperations;

    modifier onlyBorrowerOperations() {
        require(msg.sender == borrowerOperations, "LendingPool: Unauthorized call");
        _;
    }

    constructor(PoolDepositVoucher _voucherToken, address _borrowerOperations) public {
        voucherToken = _voucherToken;
        baseToken = _voucherToken.baseToken();
        borrowerOperations = _borrowerOperations;
    }

    function take(uint256 amount) public onlyBorrowerOperations {
        baseToken.transfer(borrowerOperations, amount);
    }

    function give(uint256 amount) public onlyBorrowerOperations {
        baseToken.transferFrom(borrowerOperations, address(this), amount);
    }

    function deposit(uint256 amount) public {
        if (baseToken.transferFrom(msg.sender, address(this), amount)) {
            voucherToken.mint(msg.sender, amount);
        }
    }

    function withdraw(uint256 amount) public {
        voucherToken.burn(msg.sender, amount);
        // FIXME: implement available balance check.
        // HACK: just return available funds and revert on falure to comply.
        // HACK: dont even check what the correct balance is, treat vouchers as a simple wrapper
        baseToken.transfer(msg.sender, amount);
    }
}
