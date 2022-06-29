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

    function setUp() public {
        token = new MockToken();
        lqtyToken = new MockToken();
        token.mint(address(this), 1337 * 1e18);
        lp = new MockLendingPool(IERC20(address(token)));
        token.approve(address(lp), 100 * 1e18);
        lp.give(100 * 1e18);

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
        console.log(pf.getPrice(), pf.fetchPrice());

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

        makeFD(address(bo));

        bo.setAddresses(
            address(tm),
            address(ap),
            address(dp),
            address(sp),
            address(gp),
            address(csp),
            address(pf),
            address(token),
            address(st),
            address(lqtyToken),
            address(lp),
            address(fd)
        );
    }

    function makeFD(address bo) internal {
        fd = new FeeDistributor(
            address(bo),
            IERC20(address(token)),
            address(1),
            address(2)
        );
    }

    function testOpenTrove() public {
        console.log("TESTOPENTROVE", bo.priceFeed().fetchPrice());
        vm.deal(BORROWER, 2<<128);
        vm.prank(BORROWER);
        bo.openTrove(
            (1e18 / 1000) * 6,
            1e18,
            address(0),
            address(0)
        );
    }
}