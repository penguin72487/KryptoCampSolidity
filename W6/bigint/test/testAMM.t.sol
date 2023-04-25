// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/simpleamm.sol";
import "../src/erc20.sol";

contract TestSimpleAMMTest is Test {
    AMM public ammInstance;
    testGaoDuckToken public tGD;
    address public user1;
    address public user2;
    event logString(string);
    event logUint(uint256);
    event log(string indexed key, uint256 value);



   function setUp() external {
    tGD = new testGaoDuckToken("testGaoDuck", "tGD");
    ammInstance = new AMM(address(tGD));
    
    user1 = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    user2 = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

    tGD.mint(user1, 2000);
    tGD.mint(user2, 2000);

    // Transfer Ether from the current account to user1
    payable(user1).transfer(50 ether);
    payable(user2).transfer(50 ether);

    vm.prank(user1);
    tGD.approve(address(ammInstance), 1000 * 1e18);
    vm.prank(user2);
    tGD.approve(address(ammInstance), 1000 * 1e18);
}



    function testExample() external {
        uint256 initialBalanceUser1 = tGD.balanceOf(user1);
        uint256 initialBalanceUser2 = tGD.balanceOf(user2);
        uint256 initialEthBalanceUser1 = address(user1).balance;
        uint256 initialEthBalanceUser2 = address(user2).balance;
        emit log("initialBalanceUser1", initialBalanceUser1);
        emit log("initialBalanceUser2", initialBalanceUser2);
        emit log("initialEthBalanceUser1", initialEthBalanceUser1);
        emit log("initialEthBalanceUser2", initialEthBalanceUser2);
        emit log("tGD.balanceOf(address(ammInstance))", tGD.balanceOf(address(ammInstance)));
        emit log("address(ammInstance).balance", address(ammInstance).balance);
        emit log("address(this).balance", address(this).balance);
        emit log("address(tGD).balance", address(tGD).balance);
        emit log("address(user1).balance", address(user1).balance);
        emit log("address(user2).balance", address(user2).balance);

        // User 1 adds liquidity
        vm.prank(user1);
        ammInstance.addLiquidity{value: 10 ether}(1000 * 1e18);

        uint256 lpBalanceUser1 = ammInstance.balanceOf(user1);
        assertTrue(lpBalanceUser1 > 0, "User 1 should have received LP tokens");

        emit log("lpBalanceUser1", lpBalanceUser1);

        // User 2 swaps ETH for tGD
        uint256 amountIn = 1 ether;
        vm.prank(user2);
        uint256 amountOut = ammInstance.swap{value: amountIn}(amountIn);

        assertTrue(amountOut > 0, "User 2 should have received tGD tokens");
        assertEq(tGD.balanceOf(user2), initialBalanceUser2 + amountOut, "User 2 tGD balance mismatch");
        assertEq(address(user2).balance, initialEthBalanceUser2 - amountIn, "User 2 ETH balance mismatch");

        emit log("amountOut", amountOut);

        // User 1 removes liquidity
        // vm.prank(user1);
        // (uint256 amount0, uint256 amount1) = ammInstance.removeLiquidity(lpBalanceUser1);

        // assertTrue(amount0 > 0 && amount1 > 0, "User 1 should have received ETH and tGD");
        // assertEq(tGD.balanceOf(user1), initialBalanceUser1 + amount1, "User 1 tGD balance mismatch");
        // assertEq(address(user1).balance, initialEthBalanceUser1 + amount0, "User 1 ETH balance mismatch");
    }

}