pragma solidity ^0.6.11;

import "src/StableOutput/FeeDistributor.sol";
import "forge-std/Test.sol";
import "../mocks/MockToken.sol";

contract BOMock {
    MockToken public token;

    constructor() public {
        token = new MockToken();
        token.mint(address(this), 1337 * 1e18);
    }

    function pushFees(uint256 amount, address to) public {
        token.approve(to, amount);
        FeeDistributor(to).pushFees(amount);
    }
}

contract FeeDistributorTest is Test {
    BOMock public borrowerOperations = new BOMock();
    MockToken public token;
    FeeDistributor public fd;

    address constant public DEV_WALLET = address(uint(-1));
    address constant public LENDING_POOL = address(uint(-2));

    function setUp() public {
        token = borrowerOperations.token();
    }

    modifier beforeEach() {
        fd = new FeeDistributor(
            address(borrowerOperations),
            IERC20(address(token)),
            DEV_WALLET,
            LENDING_POOL
        );
        _;
    }

    function testEverythingIsSetUp() public beforeEach {
        assertGt(uint(address(borrowerOperations)), 0, "BO");
        assertGt(uint(address(token)), 0, "TK");
        assertGt(token.balanceOf(address(borrowerOperations)), 0, "BAL");
    }

    function testFeesCanBePushed() public beforeEach {
        borrowerOperations.pushFees(10, address(fd));
    }

    function testFeeSplit() public beforeEach {
        borrowerOperations.pushFees(100, address(fd));
        assertEq(
            fd.totalCollectedFees(),
            100
        );
        assertEq(
            fd.collectedFeesFor(DEV_WALLET),
            10
        );
        assertEq(
            fd.collectedFeesFor(LENDING_POOL),
            90
        );
    }

    function testPullFees() public beforeEach {
        borrowerOperations.pushFees(100, address(fd));
        vm.prank(DEV_WALLET);
        fd.pullFees(10);
    }

    function testCannotPullFees() public beforeEach {
        uint toPull = 50;
        borrowerOperations.pushFees(100, address(fd));
        assertLt(
            fd.collectedFeesFor(DEV_WALLET), toPull
        );
        vm.startPrank(DEV_WALLET);

        vm.expectRevert("FD: cant pull fees");
        fd.pullFees(toPull);

        vm.stopPrank();
    }

    function testAvailableFees() public beforeEach {
        borrowerOperations.pushFees(100, address(fd));
        assertEq(
            fd.availableFeesToCollect(LENDING_POOL),
            90
        );

        vm.prank(LENDING_POOL);
        fd.pullFees(45);
        
        assertEq(
            fd.availableFeesToCollect(LENDING_POOL),
            45
        );
    }
}