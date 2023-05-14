// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/simpleAMMV6ERC.sol";
import "../src/erc20.sol";

contract TestSimpleAMMTest is Test {
    AMM public ammInstance;
    testGaoDuckToken public token0;
    testGaoDuckToken public token1;
    address public user1;
    address public user2;

    function setUp() external {
        token0 = new testGaoDuckToken("Token0", "TK0");
        token1 = new testGaoDuckToken("Token1", "TK1");
        ammInstance = new AMM(address(token0), address(token1));
        
        user1 = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        user2 = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

        token0.mint(user1, 40000 * 10**18);
        token0.mint(user2, 40000 * 10**18);
        token1.mint(user1, 40000 * 10**18);
        token1.mint(user2, 40000 * 10**18);

        payable(user1).transfer(50 ether);
        payable(user2).transfer(50 ether);
        
        vm.prank(user1);
        token0.approve(address(ammInstance), 40000 * 10**18);
        token1.approve(address(ammInstance), 40000 * 10**18);
        vm.prank(user2);
        token0.approve(address(ammInstance), 40000 * 10**18);
        token1.approve(address(ammInstance), 40000 * 10**18);
    }
    // function run() external {
    //     testAddLiquidity();
    //     // testSwap();
    //     // testSwapTokenForToken1();
    //     // testSwap_WithSlipLock();
    //     // testSwapTokenForToken1_WithSlipLock();
    //     // testRemoveLiquidity();
    // }

    function testAddLiquidity() public {
        uint256 initialBalanceUser1 = token0.balanceOf(user1);
        uint256 initialBalanceUser2 = token1.balanceOf(user2);


        vm.prank(user1);
        ammInstance.addLiquidity(1000 * 10**18, 1000 * 10**18);

        uint256 lpBalanceUser1 = ammInstance.balanceOf(user1);
        assertTrue(lpBalanceUser1 > 0, "User 1 should have received LP tokens");

        vm.prank(user2);
        ammInstance.addLiquidity(2000 * 10**18, 2000 * 10**18);

        uint256 lpBalanceUser2 = ammInstance.balanceOf(user2);
        assertTrue(lpBalanceUser2 > 0, "User 2 should have received LP tokens");
    }


    // function testSwap() public {
    //     uint256 initialBalanceUser1 = token0.balanceOf(user1);
    //     uint256 initialBalanceUser2 = token1.balanceOf(user2);
        
    //     vm.prank(user1);
    //     ammInstance.addLiquidity{value: 10 ether}(1000 * 10**18, 1000 * 10**18);
    //     uint256 lpBalanceUser1 = ammInstance.balanceOf(user1);
        
    //     vm.prank(user2);
    //     uint256 amountIn = 1 ether;
    //     uint256 amountOut = ammInstance.swap(amountIn);

    //     assertTrue(amountOut > 0, "User 2 should have received token0 tokens");
    //     assertEq(token0.balanceOf(user2), initialBalanceUser2 + amountOut, "User 2 token0 balance mismatch");
    // }

    //     function testSwapTokenForToken1() external {
    //     uint256 initialBalanceUser1 = token0.balanceOf(user1);
    //     uint256 initialBalanceUser2 = token1.balanceOf(user2);
        
    //     vm.prank(user1);
    //     ammInstance.addLiquidity{value: 10 ether}(1000 * 10**18, 1000 * 10**18);
        
    //     vm.prank(user2);
    //     uint256 amountIn = 100 * 10**18;
    //     uint256 amountOut = ammInstance.swapTokenForToken1(amountIn);

    //     assertTrue(amountOut > 0, "User 2 should have received token1 tokens");
    //     assertEq(token1.balanceOf(user2), initialBalanceUser2 + amountOut, "User 2 token1 balance mismatch");
    // }

    // function testSwap_WithSlipLock() external {
    //     uint256 initialBalanceUser2 = token0.balanceOf(user2);

    //     vm.prank(user2);
    //     ammInstance.addLiquidity{value: 10 ether}(1000 * 10**18, 1000 * 10**18);

    //     uint256 amountIn = 1 ether;
    //     uint256 forwardOutput = ammInstance.getPredictOutputToken1(amountIn);
    //     uint256 slipLock = 5;
    //     uint256 amountOut = ammInstance.swap_WithSlipLock(amountIn, forwardOutput, slipLock);

    //     assertTrue(amountOut >= (forwardOutput * (1000 - slipLock) / 1000), "SlipLock not applied");
    //     assertEq(token0.balanceOf(user2), initialBalanceUser2 + amountOut, "User 2 token0 balance mismatch");
    // }

    // function testSwapTokenForToken1_WithSlipLock() external {
    //     uint256 initialBalanceUser2 = token1.balanceOf(user2);
    //     vm.prank(user2);
    //     ammInstance.addLiquidity{value: 10 ether}(1000 * 10**18, 1000 * 10**18);

    //     uint256 amountIn = 100 * 10**18;
    //     uint256 forwardOutput = ammInstance.getPredictOutputToken0(amountIn);
    //     uint256 slipLock = 5;
    //     uint256 amountOut = ammInstance.swapTokenForToken1_WithSlipLock(amountIn, forwardOutput, slipLock);

    //     assertTrue(amountOut >= (forwardOutput * (1000 - slipLock) / 1000), "SlipLock not applied");
    //     assertEq(token1.balanceOf(user2), initialBalanceUser2 + amountOut, "User 2 token1 balance mismatch");
    // }
    // function testRemoveLiquidity() external {
    //     uint256 initialBalanceUser1 = token0.balanceOf(user1);
    //     uint256 initialBalanceUser2 = token1.balanceOf(user2);
    //     uint256 initialEthBalanceUser1 = address(user1).balance;
    //     uint256 initialEthBalanceUser2 = address(user2).balance;
    //     vm.prank(user1);
    //     ammInstance.addLiquidity{value: 10 ether}(1000 * 10**18, 1000 * 10**18);

    //     uint256 lpBalanceUser1 = ammInstance.sharesOf(user1);
    //     uint256 lpBalanceUser2 = ammInstance.sharesOf(user2);

    //     (uint256 amount0, uint256 amount1) = ammInstance.removeLiquidity(lpBalanceUser1);
    //     assertTrue(amount0 > 0 && amount1 > 0, "User 1 should have received tokens");
    //     assertEq(token0.balanceOf(user1), initialBalanceUser1 + amount0, "User 1 token0 balance mismatch");
    //     assertEq(token1.balanceOf(user1), initialBalanceUser1 + amount1, "User 1 token1 balance mismatch");
    //     assertEq(address(user1).balance, initialEthBalanceUser1, "User 1 ETH balance should not change");
    //     vm.prank(user2);
    //     (amount0, amount1) = ammInstance.removeLiquidity(lpBalanceUser2);
    //     assertTrue(amount0 > 0 && amount1 > 0, "User 2 should have received tokens");
    //     assertEq(token0.balanceOf(user2), initialBalanceUser2 + amount0, "User 2 token0 balance mismatch");
    //     assertEq(token1.balanceOf(user2), initialBalanceUser2 + amount1, "User 2 token1 balance mismatch");
    //     assertEq(address(user2).balance, initialEthBalanceUser2, "User 2 ETH balance should not change");
    // }

}

