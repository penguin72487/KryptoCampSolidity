// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/simpleAMMV6.sol";
import "../src/erc20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract TestExtendedAMM is Test {
    AMM public ammInstance;
    testGaoDuckToken public tGD;
    address public user1;
    address public user2;
    address public user3;
    address public user4;

    function setUp() external {
        tGD = new testGaoDuckToken("testGaoDuck", "tGD");
        ammInstance = new AMM(address(tGD));
        
        user1 = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        user2 = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        user3 = address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
        user4 = address(0x90F79bf6EB2c4f870365E785982E1f101E93b906);

        tGD.mint(user1, 38000);
        tGD.mint(user2, 38000);
        tGD.mint(user3, 38000);
        tGD.mint(user4, 38000);

        // Transfer Ether from the current account to users
        payable(user1).transfer(50 ether);
        payable(user2).transfer(50 ether);
        payable(user3).transfer(50 ether);
        payable(user4).transfer(50 ether);

        vm.prank(user1);
        tGD.approve(address(ammInstance), 4000 * 1e18);
        vm.prank(user2);
        tGD.approve(address(ammInstance), 4000 * 1e18);
        vm.prank(user3);
        tGD.approve(address(ammInstance), 4000 * 1e18);
        vm.prank(user4);
        tGD.approve(address(ammInstance), 4000 * 1e18);
    }

    function testAddLiquidity() public {
        vm.prank(user1);
        ammInstance.addLiquidity{value: 10 ether}(1000 * 1e18);

        uint256 lpBalanceUser1 = ammInstance.balanceOf(user1);
        assertTrue(lpBalanceUser1 > 0, "User 1 should have received LP tokens");

        vm.prank(user2);
        ammInstance.addLiquidity{value: 5 ether}(500 * 1e18);

        uint256 lpBalanceUser2 = ammInstance.balanceOf(user2);
        assertTrue(lpBalanceUser2 > 0, "User 2 should have received LP tokens");
    }
    function testSwap() external {
        testAddLiquidity();
        // User 1 swap
        vm.prank(user1);
        uint256 initialEthBalanceUser1 = address(user1).balance;
        uint256 initialTokenBalanceUser1 = tGD.balanceOf(user1);
        emit log_uint(initialEthBalanceUser1);
        emit log_uint(initialTokenBalanceUser1);

        uint256 ethAmountIn = 1 ether;
        uint256 tokenAmountOut = ammInstance.getInETHPredictOutputERC(ethAmountIn);
        ammInstance.swap{value: ethAmountIn}(ethAmountIn);
        emit log_uint(initialEthBalanceUser1);
        emit log_uint(initialTokenBalanceUser1);
        assertEq(address(user1).balance, initialEthBalanceUser1 - ethAmountIn, "User 1 ETH balance mismatch");
        assertEq(tGD.balanceOf(user1), initialTokenBalanceUser1 + tokenAmountOut, "User 1 tGD balance mismatch");

        // User 2 swap
        vm.prank(user2);
        uint256 initialEthBalanceUser2 = address(user2).balance;
        uint256 initialTokenBalanceUser2 = tGD.balanceOf(user2);

        ethAmountIn = 1 ether;
        tokenAmountOut = ammInstance.getInETHPredictOutputERC(ethAmountIn);
        ammInstance.swap{value: ethAmountIn}(ethAmountIn);

        assertEq(address(user2).balance, initialEthBalanceUser2 - ethAmountIn, "User 2 ETH balance mismatch");
        assertEq(tGD.balanceOf(user2), initialTokenBalanceUser2 + tokenAmountOut, "User 2 tGD balance mismatch");
    }

    // function testSlipLockSwap() external {
    //     // User 1 slip lock swap
    //     vm.prank(user1);
    //     uint256 initialEthBalanceUser1 = address(user1).balance;
    //     uint256 initialTokenBalanceUser1 = tGD.balanceOf(user1);

    //     uint256 ethAmountIn = 1 ether;
    //     uint256 slipLock = 5;
    //     uint256 forwardOutput = ammInstance.getInETHPredictOutputERC(ethAmountIn);
    //     ammInstance.swap_WithSlipLock{value: ethAmountIn}(ethAmountIn, forwardOutput, slipLock);

    //     assertEq(address(user1).balance, initialEthBalanceUser1 - ethAmountIn, "User 1 ETH balance mismatch");
    //     assertEq(tGD.balanceOf(user1), initialTokenBalanceUser1 + forwardOutput, "User 1 tGD balance mismatch");

    //     // User 2 slip lock swap
    //     vm.prank(user2);
    //     uint256 initialEthBalanceUser2 = address(user2).balance;
    //     uint256 initialTokenBalanceUser2 = tGD.balanceOf(user2);

    //     ethAmountIn = 1 ether;
    //     forwardOutput = ammInstance.getInETHPredictOutputERC(ethAmountIn);
    //     ammInstance.swap_WithSlipLock{value: ethAmountIn}(ethAmountIn, forwardOutput, slipLock);

    //     assertEq(address(user2).balance, initialEthBalanceUser2 - ethAmountIn, "User 2 ETH balance mismatch");
    //     assertEq(tGD.balanceOf(user2), initialTokenBalanceUser2 + forwardOutput, "User 2 tGD balance mismatch");
    // }

    // function testSlipLockSwapTokenForETH() external {
    //     // User 1 slip lock swap tGD for ETH
    //     vm.prank(user1);
    //     uint256 initialEthBalanceUser1 = address(user1).balance;
    //     uint256 initialTokenBalanceUser1 = tGD.balanceOf(user1);

    //     uint256 tokenAmountIn = 1e18;
    //     uint256 slipLock = 5;
    //     uint256 forwardOutput = ammInstance.getInERCPredictOutputETH(tokenAmountIn);
    //     ammInstance.swapTokenForETH_WithSlipLock(tokenAmountIn, forwardOutput, slipLock);

    //     assertEq(address(user1).balance, initialEthBalanceUser1 + forwardOutput, "User 1 ETH balance mismatch");
    //     assertEq(tGD.balanceOf(user1), initialTokenBalanceUser1 - tokenAmountIn, "User 1 tGD balance mismatch");

    //     // User 2 slip lock swap tGD for ETH
    //     vm.prank(user2);
    //     uint256 initialEthBalanceUser2 = address(user2).balance;
    //     uint256 initialTokenBalanceUser2 = tGD.balanceOf(user2);

    //     tokenAmountIn = 1e18;
    //     forwardOutput = ammInstance.getInERCPredictOutputETH(tokenAmountIn);
    //     ammInstance.swapTokenForETH_WithSlipLock(tokenAmountIn, forwardOutput, slipLock);

    //     assertEq(address(user2).balance, initialEthBalanceUser2 + forwardOutput, "User 2 ETH balance mismatch");
    //     assertEq(tGD.balanceOf(user2), initialTokenBalanceUser2 - tokenAmountIn, "User 2 tGD balance mismatch");
    // }

    // function testRemoveLiquidity() external {
    //     // User 1 remove liquidity
    //     vm.prank(user1);
    //     uint256 initialEthBalanceUser1 = address(user1).balance;
    //     uint256 initialTokenBalanceUser1 = tGD.balanceOf(user1);
    //     uint256 user1Shares = ammInstance.sharesOf(user1);

    //     (uint256 amount0, uint256 amount1) = ammInstance.removeLiquidity(user1Shares);

    //     assertEq(address(user1).balance, initialEthBalanceUser1 + amount0, "User 1 ETH balance mismatch");
    //     assertEq(tGD.balanceOf(user1), initialTokenBalanceUser1 + amount1, "User 1 tGD balance mismatch");
    // }


}