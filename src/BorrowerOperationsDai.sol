// SPDX-License-Identifier: GPL3
pragma solidity ^0.6.11;
import "liquity/BorrowerOperations.sol";
import "./StableInput/ILendingPool.sol";
import "./StableOutput/IFeeDistributor.sol";

library Math {
    uint256 constant public MAX_UINT = 2**256 - 1;
}

/**
 * This contract replaces functionality found in Liquity's
 * original BorrowerOperations contract to instead of
 * manipulating a protocol-owned token, pull and push
 * balances from a "Lending Pool".
 *
 * Function names are kept the same to require the least
 * amount of changes necessary to Liquity's base contracts.
 *
 * @dev for clarification on what this contract's methods
 *      do, check out `BorrowerOperations.sol`
 */
contract BorrowerOperationsDai is BorrowerOperations {
    ILendingPool public _lendingPool;
    IFeeDistributor public _feeDistributor;

    // FIXME: Use BorrowerOperations' constructor and use _LUSD in place of _dai.
    // NOTE:  This is handled by calling `setAddresses(address...)` defined in BorrowerOperations.sol

    // TODO:  Take fee from balance taken from the lending pool.
    //        Effectively, set the user's trove debt to their required dai amount
    //        plus the fees while just giving them what they asked for.

    constructor(ILendingPool lendingPool, IFeeDistributor feeDistributor, IERC20 dai) public {
        _lendingPool = lendingPool;
        _feeDistributor = feeDistributor;
    }

    modifier ensureAllowanceIsAtLeast(address from, address to, uint256 requiredAllowance) {
        if (lusdToken.allowance(from, to) < requiredAllowance) {
            require(from == address(this), "BorrowerOperationsDai: Not enough DAI allowance for this operation");
            lusdToken.approve(to, Math.MAX_UINT);
        }
        _;
    }

    /**
     * LUSD-minting methods, to be replaced with lendingPool.take(...)
     */

    function _withdrawLUSD(
        IActivePool _activePool,
        ILUSDToken _lusdToken,
        address _account,
        uint _LUSDAmount,
        uint _netDebtIncrease
    ) internal override {
        _activePool.increaseLUSDDebt(_netDebtIncrease);
        _lendingPool.take(_LUSDAmount);
        _lusdToken.transfer(_account, _LUSDAmount);
    }

    /**
     * @notice this function is responsible for distributing the
     *         upfront fee taken by Liquity's Troves. Since we
     * .       aren't actually minting/burning tokens, we should
     *         take the fee from the borrowed amount, and push
     * .       that into the FeeDistributor
     */
    function _triggerBorrowingFee(
        ITroveManager _troveManager,
        ILUSDToken _lusdToken,
        uint _LUSDAmount,
        uint _maxFeePercentage
    ) internal override returns (uint) {
        _troveManager.decayBaseRateFromBorrowing(); // decay the baseRate state variable
        uint LUSDFee = _troveManager.getBorrowingFee(_LUSDAmount);

        _requireUserAcceptsFee(LUSDFee, _LUSDAmount, _maxFeePercentage);

        // increase user's debt by _LUSDFee, giving the fee to the _feeDistributor
        _withdrawLUSD(activePool, _lusdToken, address(_feeDistributor), LUSDFee, LUSDFee);

        _lusdToken.approve(address(_feeDistributor), LUSDFee);
        _feeDistributor.pushFees(LUSDFee);
        return LUSDFee;
    }

    /**
     * LUSD-burning methods, to be replaced with lendingPool.give(...)
     */

    function _repayLUSD(
        IActivePool _activePool,
        ILUSDToken _lusdToken,
        address _account,
        uint _LUSD
    ) internal override ensureAllowanceIsAtLeast(address(this), address(_lendingPool), _LUSD) {
        _activePool.decreaseLUSDDebt(_LUSD);
        _lusdToken.transferFrom(_account, address(this), _LUSD);
        _lendingPool.give(_LUSD);
    }

}
