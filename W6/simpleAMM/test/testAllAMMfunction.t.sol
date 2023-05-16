// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/simpleAMMV5.sol";
import "../src/erc20.sol";

contract TestSimpleAMMTest is Test {
    AMM public ammInstance;
    testGaoDuckToken public tGD;
    address public user1;
    address public user2;

    function setUp() external {
        tGD = new testGaoDuckToken("testGaoDuck", "tGD",18);
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

    function test_addLiquidity() public {
        uint256 shares;
        // User1 adds liquidity
        vm.prank(user1);
        shares = ammInstance.addLiquidity{value: 1 ether}(500 * 1e18);
        assertEq(ammInstance.balanceOf(user1), shares);
        assertEq(ammInstance.totalSupply(), shares);
    }

    function test_swap() public {
        // User1 adds liquidity
        test_addLiquidity();

        uint256 initialBalance = tGD.balanceOf(user2);
        uint256 amountOut;

        // User2 swaps ETH for tokens
        vm.prank(user2);
        amountOut = ammInstance.swap{value: 0.5 ether}(0.5 ether);
        assertGt(tGD.balanceOf(user2), initialBalance);
    }

    function test_swapTokenForETH() public {
        // User1 adds liquidity
        test_addLiquidity();

        uint256 initialBalance = address(user2).balance;
        uint256 amountOut;

        // User2 swaps tokens for ETH
        vm.prank(user2);
        amountOut = ammInstance.swapTokenForETH(250 * 1e18);
        assertGt(address(user2).balance, initialBalance);
    }

    function test_removeLiquidity() public {
        // User1 adds liquidity
        test_addLiquidity();

        uint256 shares = ammInstance.balanceOf(user1);
        uint256 initialEthBalance = address(user1).balance;
        uint256 initialTokenBalance = tGD.balanceOf(user1);
        uint256 amount0;
        uint256 amount1;

        // User1 removes liquidity
        vm.prank(user1);
        (amount0, amount1) = ammInstance.removeLiquidity(shares);

        assertEq(ammInstance.balanceOf(user1), 0);
        assertGt(address(user1).balance, initialEthBalance);
        assertGt(tGD.balanceOf(user1), initialTokenBalance);
    }
    function test_removeAllLiquidity() public {
        // User1 adds liquidity
        test_addLiquidity();

        uint256 initialEthBalance = address(user1).balance;
        uint256 initialTokenBalance = tGD.balanceOf(user1);

        uint256 amount0;
        uint256 amount1;

        // User1 removes all liquidity
        vm.prank(user1);
        (amount0, amount1) = ammInstance.removeAllLiquidity(user1);

        assertEq(ammInstance.balanceOf(user1), 0);
        assertGt(address(user1).balance, initialEthBalance);
        assertGt(tGD.balanceOf(user1), initialTokenBalance);
    }

    function test_my_shares() public {
        // User1 adds liquidity
        test_addLiquidity();

        uint256 shares = ammInstance.balanceOf(user1);

        // User1 checks their shares
        vm.prank(user1);
        assertEq(ammInstance.my_shars(), shares);
    }

    function test_sharesOf() public {
        // User1 adds liquidity
        test_addLiquidity();

        uint256 shares = ammInstance.balanceOf(user1);

        // User2 checks User1's shares
        vm.prank(user2);
        assertEq(ammInstance.sharesOf(user1), shares);
    }

    function test_getETHPrice() public {
        // User1 adds liquidity
        test_addLiquidity();

        uint256 price = ammInstance.getETHPrice();
        assertGt(price, 0);
    }

    function test_getERCPrice() public {
        // User1 adds liquidity
        test_addLiquidity();

        uint256 price = ammInstance.getERCPrice();
        assertGt(price, 0);
    }
    function test_getPredictOutputETH() public {
        // User1 adds liquidity
        test_addLiquidity();

        uint256 price = ammInstance.getPredictOutputETH(100 * 1e18);
        assertGt(price, 0);
    }
    function test_getPredictOutputERC() public {
        // User1 adds liquidity
        test_addLiquidity();

        uint256 price = ammInstance.getPredictOutputERC(100 * 1e18);
        assertGt(price, 0);
    }

}
  



