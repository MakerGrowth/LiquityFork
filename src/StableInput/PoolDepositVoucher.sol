pragma solidity ^0.6.11;

import "liquity/Dependencies/IERC20.sol";
import "liquity/Dependencies/IERC2612.sol";
import "./ILendingPool.sol";


contract PoolDepositVoucher is IERC20 {
    ILendingPool public lendingPool;
    IERC20 public baseToken;
    uint8 public override decimals;
    uint256 public override totalSupply;

    modifier onlyLendingPool() {
        require(
            msg.sender == address(lendingPool), "PDV: unauthorized call"
        );
        _;
    }

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    string constant public ERROR_BASE_TOKEN_NOT_APPROVED_SENDER = "PDV: Base token not approved to coinpool contract.";

    constructor(IERC20 _baseToken) public {
        baseToken = _baseToken;
        decimals = _baseToken.decimals();
    }

    function name() public override view returns (string memory) {
        return string(
            abi.encodePacked("Lending Pool Deposited " , baseToken.name())
        );
    }

    function symbol() public override view returns (string memory) {
        return string(
            abi.encodePacked("ldp", baseToken.symbol())
        );
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external override returns (bool){
        allowance[msg.sender][spender] -= subtractedValue;
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external override returns (bool){
        allowance[msg.sender][spender] += addedValue;
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(balanceOf[from] >= value, "ERC20 not enough funds");
        _onBeforeTransfer(from, to, value);
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _onBeforeTransfer(msg.sender, recipient, amount);
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(
            allowance[sender][msg.sender] >= amount, "ERC20: allowance too low"
        );
        _onBeforeTransfer(sender, recipient, amount);
        _transfer(sender, recipient, amount);
    }

    function mint(address to, uint256 amount) public onlyLendingPool returns (bool) {
        balanceOf[to] += amount;
        _onBeforeTransfer(address(0), to, amount);
        emit Transfer(address(0), to, amount);
        return true;
    }

    function burn(address from, uint256 amount) public onlyLendingPool returns (bool) {
        balanceOf[from] -= amount;
        _onBeforeTransfer(from, address(0), amount);

    }

    function _onBeforeTransfer(address from, address to, uint256 amount) internal {
        if (to == address(0)) {
            //coinpool.withdraw(msg.sender, amount);
        }
    }
}

