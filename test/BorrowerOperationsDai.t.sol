pragma solidity ^0.6.11;

import "liquity/Dependencies/LiquityBase.sol";
import "src/BorrowerOperationsDai.sol";
import "src/StableOutput/FeeDistributor.sol";
import "./mocks/MockLendingPool.sol";
import "./mocks/MockToken.sol";
import "./mocks/MockPriceFeed.sol";

import {console as console, Test as FTest} from "forge-std/Test.sol";

/**
 * Liquity imports
 */
import "liquity/TroveManager.sol";
import "liquity/ActivePool.sol";
import "liquity/DefaultPool.sol";
import "liquity/StabilityPool.sol";
import "liquity/GasPool.sol";
import "liquity/CollSurplusPool.sol";
import "liquity/TestContracts/PriceFeedTestnet.sol";
import "liquity/SortedTroves.sol";
import "liquity/LQTY/LQTYStaking.sol";
import "liquity/LQTY/CommunityIssuance.sol";


contract BorrowerOperationsDaiTest is FTest {
    BorrowerOperationsDai public bo;
    MockToken public token;
    MockToken public lqtyToken;
    FeeDistributor public fd;
    MockLendingPool public lp;

    address public constant BORROWER = address(uint(-2));

    function deployContracts() internal {
        token = new MockToken();
        lqtyToken = new MockToken();
        token.mint(address(this), 50_000 * 1e18);
        lp = new MockLendingPool(IERC20(address(token)));
        token.approve(address(lp), 1 << 255);
        lp.give(50_000 * 1e18);

        bo = new BorrowerOperationsDai();
        TroveManager tm = new TroveManager();
        ActivePool ap = new ActivePool();
        DefaultPool dp = new DefaultPool();
        StabilityPool sp = new StabilityPool();
        GasPool gp = new GasPool();
        CollSurplusPool csp = new CollSurplusPool();
        MockPriceFeed pf = new MockPriceFeed();
        SortedTroves st = new SortedTroves();
        LQTYStaking stk = new LQTYStaking();
        CommunityIssuance ci = new CommunityIssuance();

        lqtyToken.mint(address(ci), 1<<255);

        pf.setPrice(2200 * 1e18);

        // Set addresses for all used contracts
        // NOTE: we're using as many base LQTY contracts here as possible
        tm.setAddresses(
            address(bo),
            address(ap),
            address(dp),
            address(sp),
            address(gp),
            address(csp),
            address(pf),
            address(token),
            address(st),
            address(lqtyToken),
            address(stk)
        );
        ap.setAddresses(
            address(bo),
            address(tm),
            address(sp),
            address(dp)
        );
        dp.setAddresses(
            address(tm),
            address(ap)
        );
        sp.setAddresses(
            address(bo),
            address(tm),
            address(ap),
            address(token),
            address(st),
            address(pf),
            address(ci)
        );
        csp.setAddresses(
            address(bo),
            address(tm),
            address(ap)
        );
        stk.setAddresses(
            address(lqtyToken),
            address(token),
            address(tm),
            address(bo),
            address(ap)
        );
        ci.setAddresses(
            address(lqtyToken),
            address(sp)
        );
        st.setParams(
            10_000,
            address(tm),
            address(bo)
        );

        makeFD(address(bo));

        bo.setAddresses(
            address(tm),
            address(ap),
            address(dp),
            address(sp),
            address(gp),
            address(csp),
            address(pf),
            address(st),
            address(token),
            address(stk),
            address(lp),
            address(fd)
        );
    }

    function setUp() public {
        deployContracts();
    }

    modifier beforeEach() {
        deployContracts();
        vm.deal(BORROWER, 1<<255);
        _;
    }

    function makeFD(address bo) internal {
        fd = new FeeDistributor(
            address(bo),
            IERC20(address(token)),
            address(1),
            address(2)
        );
    }

    function testOpenTrove() public beforeEach {
        vm.deal(BORROWER, 2<<128);
        vm.prank(BORROWER);
        bo.openTrove{
            value: 3e18
        }(
            (1e18 / 1000) * 5,
            1800e18,    // MIN_NET_DEBT specified in LiquityBase
            address(0),
            address(0)
        );

        assertEq(
            token.balanceOf(BORROWER), 1800e18
        );
        assertEq(
            token.balanceOf(address(fd)), token.balanceOf(BORROWER) * 5 / 1000 // 5pct fee
        );
    }

    modifier openTrove(uint256 collateralAmt, uint256 daiRequired) {
        doOpenTrove(collateralAmt, daiRequired);
        _;
    }

    function doOpenTrove(uint256 collateralAmt, uint256 daiRequired) internal {
        vm.prank(BORROWER);
        bo.openTrove{
            value: collateralAmt
        }(
            (1e18 / 1000) * 5,
            daiRequired,    // MIN_NET_DEBT specified in LiquityBase
            address(0),
            address(0)
        );

    }

    function testTroveOpeningGivesExpectedAmountOfDai() public beforeEach openTrove(3e18, 1800e18){
        assertEq(token.balanceOf(BORROWER), 1800e18);
    }

    function testTroveOpeningDepositsFeesInFeeDistributor() public beforeEach openTrove(3e18, 1800e18) {
        assertEq(token.balanceOf(address(bo.feeDistributor())), 9e18);
    }

    function testTroveOpeningPullsFeesFromLendingPool() public beforeEach {
        uint256 bal = token.balanceOf(
            address(bo.lendingPool())
        );
        doOpenTrove(3e18, 1800e18);
        uint256 newbal = token.balanceOf(
            address(bo.lendingPool())
        );
        assertLt(newbal, bal);
    }

    function testFailTroveWithLowICR() public beforeEach openTrove(1e18, 20000e18){
    }

    function testFailTroveWithMoreThanLPBalanceDebt() public beforeEach openTrove(400e18, 50_001e18) {
    }

    function testTroveDebtIsCalculatedCorrectly() public beforeEach openTrove(3e18, 1800e18) {
        
    }
}