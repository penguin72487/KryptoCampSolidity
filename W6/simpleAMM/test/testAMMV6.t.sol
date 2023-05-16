// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/simpleAMMV7.sol";
import "../src/erc20.sol";

contract TestSimpleAMMTest is Test {
    AMM public ammInstance;
    testGaoDuckToken public tGD;
    address public user1;
    address public user2;
    event logString(string);
    event logUint(uint256);
    event log(string indexed key, uint256 value);

    function setUp() public {
        tGD = new testGaoDuckToken("testGaoDuck", "tGD",18);
        ammInstance = new AMM(address(tGD),3);
        
        user1 = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        user2 = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

        tGD.mint(user1, 38000*10**18);
        tGD.mint(user2, 38000*10**18);

        // Transfer Ether from the current account to user1
        payable(user1).transfer(50 ether);
        payable(user2).transfer(50 ether);

        vm.prank(user1);
        tGD.approve(address(ammInstance), 4000 * 1e18);
        //ammInstance.addLiquidity{value: 1 ether}(1 * 1e18);
        vm.prank(user2);
        tGD.approve(address(ammInstance), 4000 * 1e18);
    }
    function run () public {
        testRemoveLiquidity();
    }

    function testAddLiquidity() public {
        vm.prank(user1);
        ammInstance.addLiquidity{value: 10 ether}(1000 * 1e18);

        uint256 lpBalanceUser1 = ammInstance.balanceOf(user1);
        assertTrue(lpBalanceUser1 > 0, "User 1 should have received LP tokens");

        vm.prank(user2);
        ammInstance.addLiquidity{value: 20 ether}(2000 * 1e18);

        uint256 lpBalanceUser2 = ammInstance.balanceOf(user2);
        assertTrue(lpBalanceUser2 > 0, "User 2 should have received LP tokens");
    }

    function testSwap() public {
        uint256 initialBalanceUser1 = tGD.balanceOf(user1);
        uint256 initialBalanceUser2 = tGD.balanceOf(user2);
        uint256 initialEthBalanceUser1 = address(user1).balance;
        uint256 initialEthBalanceUser2 = address(user2).balance;

        // User 1 adds liquidity
        vm.prank(user1);
        ammInstance.addLiquidity{value: 10 ether}(1000 * 1e18);

        uint256 lpBalanceUser1 = ammInstance.balanceOf(user1);
        assertTrue(lpBalanceUser1 > 0, "User 1 should have received LP tokens");

        // User 2 swaps ETH for tGD
        uint256 amountIn = 1 ether;
        vm.prank(user2);
        uint256 amountOut = ammInstance.swap{value: amountIn}(amountIn);

        assertTrue(amountOut > 0, "User 2 should have received tGD tokens");
        assertEq(tGD.balanceOf(user2), initialBalanceUser2 + amountOut, "User 2 tGD balance mismatch");
        assertEq(address(user2).balance, initialEthBalanceUser2 - amountIn, "User 2 ETH balance mismatch");
    }

    function testSwapTokenForETH() public {
        uint256 initialBalanceUser1 = tGD.balanceOf(user1);
        uint256 initialBalanceUser2 = tGD.balanceOf(user2);
        uint256 initialEthBalanceUser1 = address(user1).balance;
        uint256 initialEthBalanceUser2 = address(user2).balance;

        // User 1 adds liquidity
        vm.prank(user1);
        ammInstance.addLiquidity{value: 10 ether}(1000 * 1e18);

        // User 2 swaps tGD for ETH
        uint256 amountIn = 100 * 1e18;
        vm.prank(user2);
        uint256 amountOut = ammInstance.swapTokenForETH(amountIn);

        assertTrue(amountOut > 0, "User 2 should have received ETH");
        assertEq(tGD.balanceOf(user2), initialBalanceUser2 - amountIn, "User 2 tGD balance mismatch");
        assertEq(address(user2).balance, initialEthBalanceUser2 + amountOut, "User 2 ETH balance mismatch");
    }

    function testSwap_WithSlipLock() public {
        uint256 initialEthBalanceUser2 = address(user2).balance;

        // User 1 adds liquidity
        vm.prank(user1);
        ammInstance.addLiquidity{value: 10 ether}(1000 * 1e18);

        // User 2 swaps ETH for tGD with slipLock
        uint256 amountIn = 1 ether;
        uint256 forwardOutput = ammInstance.getInETHPredictOutputERC(amountIn);
        uint256 slipLock = 5;
        vm.prank(user2);
        uint256 amountOut = ammInstance.swap_WithSlipLock{value: amountIn}(amountIn,forwardOutput, slipLock);

        assertTrue(amountOut >= (forwardOutput * (1000 - slipLock) / 1000), "SlipLock not applied");
        assertEq(address(user2).balance, initialEthBalanceUser2 - amountIn, "User 2 ETH balance mismatch");
    }



    function testSwapTokenForETH_WithSlipLock() public {
        uint256 initialEthBalanceUser2 = address(user2).balance;
        uint256 initialBalanceUser2 = tGD.balanceOf(user2);

        // User 1 adds liquidity
        vm.prank(user1);
        ammInstance.addLiquidity{value: 10 ether}(1000 * 1e18);

        // User 2 swaps tGD for ETH with slipLock
        uint256 amountIn = 100 * 1e18;
        uint256 forwardOutput = ammInstance.getInERCPredictOutputETH(amountIn);
        uint256 slipLock = 5;
        vm.prank(user2);
        uint256 amountOut = ammInstance.swapTokenForETH_WithSlipLock(amountIn, forwardOutput, slipLock);

        assertTrue(amountOut >= (forwardOutput * (1000 - slipLock) / 1000), "SlipLock not applied");
        assertEq(tGD.balanceOf(user2), initialBalanceUser2 - amountIn, "User 2 tGD balance mismatch");
        assertEq(address(user2).balance, initialEthBalanceUser2 + amountOut, "User 2 ETH balance mismatch");
    }
    function testSwap_WithSlipLock_Invalid() public {
        uint256 initialEthBalanceUser2 = address(user2).balance;

        // User 1 adds liquidity
        vm.prank(user1);
        ammInstance.addLiquidity{value: 10 ether}(1000 * 1e18);

        // User 2 swaps ETH for tGD with slipLock
        uint256 amountIn = 1 ether;
        uint256 forwardOutput = ammInstance.getInETHPredictOutputERC(amountIn);
        uint256 slipLock = 5;
        vm.prank(user1);
        uint256 amountOutU1 = ammInstance.swap_WithSlipLock{value: amountIn}(amountIn,forwardOutput, slipLock);
        vm.prank(user2);
        uint256 amountOut;
        try ammInstance.swap_WithSlipLock{value: amountIn}(amountIn,forwardOutput, slipLock) {
            assertTrue(false, "SlipLock not applied");
        } catch Error(string memory reason) {
            assertEq(reason, "SlipLock", "SlipLock not applied");
        }
    }
    function testSwapTokenForETH_WithSlipLock_Invalid() public {
        uint256 initialEthBalanceUser2 = address(user2).balance;
        uint256 initialBalanceUser2 = tGD.balanceOf(user2);

        // User 1 adds liquidity
        vm.prank(user1);
        ammInstance.addLiquidity{value: 10 ether}(1000 * 1e18);

        // User 2 swaps tGD for ETH with slipLock
        uint256 amountIn = 100 * 1e18;
        uint256 forwardOutput = ammInstance.getInERCPredictOutputETH(amountIn);
        uint256 slipLock = 5;
        vm.prank(user1);
        uint256 amountOutU1 = ammInstance.swapTokenForETH_WithSlipLock(amountIn, forwardOutput, slipLock);
        vm.prank(user2);
        try ammInstance.swapTokenForETH_WithSlipLock(amountIn, forwardOutput, slipLock) {
            assertTrue(false, "SlipLock not applied");
        } catch Error(string memory reason) {
            assertEq(reason, "SlipLock", "SlipLock not applied");
        }
    }

    function testRemoveLiquidity() public {
        // User 1 adds liquidity
        vm.prank(user1);
        ammInstance.addLiquidity{value: 10 ether}(1000 * 1e18);
        uint256 initialEthBalanceUser1 = address(user1).balance;
        uint256 initialBalanceUser1 = tGD.balanceOf(user1);
        uint256 lpBalanceUser1 = ammInstance.balanceOf(user1);

        // User 1 removes liquidity
        vm.prank(user1);
        (uint256 amountETH, uint256 amountToken) = ammInstance.removeLiquidity(lpBalanceUser1);

        assertTrue(amountToken > 0 && amountETH > 0, "User 1 should have received tGD and ETH");
        assertEq(tGD.balanceOf(user1), initialBalanceUser1 + amountToken, "User 1 tGD balance mismatch");
        assertEq(address(user1).balance, initialEthBalanceUser1 + amountETH, "User 1 ETH balance mismatch");
    }
}


