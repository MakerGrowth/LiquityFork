pragma solidity ^0.6.11;

import "forge-std/Test.sol";
import "src/BorrowerOperationsDai.sol";
import "./mocks/MockToken.sol";
import "./mocks/MockLendingPool.sol";

/**
 * Liquity imports
 */
import "liquity/TroveManager.sol";
import "liquity/ActivePool.sol";
import "liquity/DefaultPool.sol";
import "liquity/StabilityPool.sol";
import "liquity/GasPool.sol";
import "liquity/CollSurplusPool.sol";
import "liquity/TestContracts/PriceFeedTester.sol";
import "liquity/SortedTroves.sol";
import "liquity/LQTY/LQTYStaking.sol";
import "liquity/LQTY/CommunityIssuance.sol";

contract BorrowerOperationsDaiTest is Test {
    BorrowerOperationsDai public bo;
    address public constant BORROWER = address(uint(-2));

    function setUp() public {
        // give BORROWER 1000 ETH
        vm.deal(BORROWER, 1000e18);

        MockToken token = new MockToken();
        MockToken lqtyToken = new MockToken();
        token.mint(address(this), 1337 * 1e18);
        MockLendingPool lp = new MockLendingPool(token);
        token.approve(100 * 1e18, address(lp));
        lp.give(100 * 1e18);

        bo = new BorrowerOperationsDai();
        TroveManager tm = new TroveManager();
        ActivePool ap = new ActivePool();
        DefaultPool dp = new DefaultPool();
        StabilityPool sp = new StabilityPool();
        GasPool gp = new GasPool();
        CollSurplusPool csp = new CollSurplusPool();
        PriceFeedTester pf = new PriceFeedTester();
        SortedTroves st = new SortedTroves();
        LQTYStaking stk = new LQTYStaking();

        pf.setLastGoodPrice(1000e18);
        pf.setStatus(
            pf.Status.chainlinkWorking
        );

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
    }

    function testOpenTrove() public {
        vm.prank(BORROWER);
        bo.openTrove(
            5,
            1e18,
            address(1),
            address(0)
        );
    }
}