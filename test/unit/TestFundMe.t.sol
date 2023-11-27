// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract TestFundMe is Test {
    address USER = makeAddr("user");
    uint256 constant FUND_AMOUNT = 100 ether;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant GAS_PRICE = 1;

    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, FUND_AMOUNT);
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    //This is testing if Minimum payable USD is $5
    function testMinimumUsdIsFive() public {
        // fundMe.fund();
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    // This is testing if `getVersion()` is working
    function testGetVersionWorking() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    // This is testing if the Owner is Msg.sender
    function testOwnerIsMsgSender() public {
        // ARRANGE
        // vm.prank(USER);
        // fundMe.fund{value: 0.1 ether}();

        // ACT

        // ASSERT
        assertEq(fundMe.getOwner(), address(msg.sender));
        // console.log(fundMe.i_owner());
        // console.log(msg.sender);
    }

    // This is testing if `fund()` reverts when ETH is not enough
    function testFundFailIfEthNotEnough() public {
        vm.prank(USER);
        vm.expectRevert();

        fundMe.fund();
        console.log(msg.sender, USER);
    }

    // This is testing that User (who calls `fund()` is msg.msg.sender)
    // Test is currently failing
    function testCallerIsNotPrankUser() public {
        vm.startPrank(USER);
        vm.deal(USER, FUND_AMOUNT);

        fundMe.fund{value: 1 ether}();
        assertEq(address(fundMe.getOwner()), msg.sender);
        vm.stopPrank();
    }

    function testFundUpdatesFunderDataStructure() public {
        // ARRANGE
        vm.startPrank(USER);

        // ACT
        fundMe.fund{value: SEND_VALUE}();

        // ASSERT
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
        vm.stopPrank();
    }

    function testAddsFunderToArrayOfFunder() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawWithMultipeFunders() public {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // Prank new address
            // Deal
            hoax(address(i), SEND_VALUE);
            // Fund
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank;

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        
    }
}
