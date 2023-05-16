// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/simpleAMMV7ERC.sol";
import "../src/erc20.sol";

contract TestSimpleAMMTest is Test {
    AMM public ammInstance;
    testGaoDuckToken public token0;
    testGaoDuckToken public token1;
    address public user1;
    address public user2;

    function setUp() external {
        token0 = new testGaoDuckToken("Token0", "TK0",8);
        token1 = new testGaoDuckToken("Token1", "TK1",18);
        ammInstance = new AMM(address(token0), address(token1),3);
        
        user1 = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        user2 = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

        token0.mint(user1, 40000 * 10**token0.decimals());
        token0.mint(user2, 40000 * 10**token0.decimals());
        token1.mint(user1, 40000 * 10**token1.decimals());
        token1.mint(user2, 40000 * 10**token1.decimals());


        payable(user1).transfer(50 ether);
        payable(user2).transfer(50 ether);
        

    }
    // function run() external {
    //     testAddLiquidity();
    //     // testSwap();
    //     // testSwapTokenForToken1();
    //     // testSwap_WithSlipLock();
    //     // testSwapTokenForToken1_WithSlipLock();
    //     // testRemoveLiquidity();
    // }

    function testAddLiquidity() external {
        uint256 amount0 = 10000 * 10**token0.decimals();
        uint256 amount1 = 10000 * 10**token1.decimals();
        vm.prank(user1);
        token0.approve(address(ammInstance), 40000 * 10**token0.decimals());
        token1.approve(address(ammInstance), 40000 * 10**token1.decimals());
        vm.prank(user2);
        token0.approve(address(ammInstance), 40000 * 10**token0.decimals());
        token1.approve(address(ammInstance), 40000 * 10**token1.decimals());
        vm.prank(user1);
        ammInstance.addLiquidity(amount0, amount1);
        assertEq(ammInstance.reserve0(), 10000 * 10**token0.decimals());
        assertEq(ammInstance.reserve1(), 10000 * 10**token1.decimals());

        vm.prank(user2);
        ammInstance.addLiquidity(amount0, amount1);
        assertEq(ammInstance.reserve0(), 20000 * 10**token0.decimals());
        assertEq(ammInstance.reserve1(), 20000 * 10**token1.decimals());
    }

    // function testRemoveLiquidity() external {
    //     vm.prank(user1);
    //     uint256 shares = ammInstance.myShares();
    //     (uint256 amount0, uint256 amount1) = ammInstance.removeLiquidity(shares / 2);
    //     assertEq(amount0, 5000 * 10**token0.decimals());
    //     assertEq(amount1, 5000 * 10**token1.decimals());

    //     vm.prank(user2);
    //     shares = ammInstance.myShares();
    //     (amount0, amount1) = ammInstance.removeLiquidity(shares / 2);
    //     assertEq(amount0, 5000 * 10**token0.decimals());
    //     assertEq(amount1, 5000 * 10**token1.decimals());
    // }

    // function testSwapToken1ForToken0() external {
    //     vm.prank(user1);
    //     uint256 amountOut = ammInstance.swapToken1ForToken0(1000 * 10**token1.decimals());
    //     assertTrue(amountOut > 0);

    //     vm.prank(user2);
    //     amountOut = ammInstance.swapToken1ForToken0(1000 * 10**token1.decimals());
    //     assertTrue(amountOut > 0);
    // }

    // function testSwapToken0ForToken1() external {
    //     vm.prank(user1);
    //     uint256 amountOut = ammInstance.swapToken0ForToken1(1000 * 10**token0.decimals());
    //     assertTrue(amountOut > 0);

    //     vm.prank(user2);
    //     amountOut = ammInstance.swapToken0ForToken1(1000 * 10**token0.decimals());
    //     assertTrue(amountOut > 0);
    // }

    // function testSwapToken1ForToken0_WithSlipLock() external {
    //     vm.prank(user1);
    //     uint256 amountOut = ammInstance.swapToken1ForToken0_WithSlipLock(1000 * 10**token1.decimals(), 500 * 10**token0.decimals(), 10);
    //     assertTrue(amountOut >= 500 * 10**token0.decimals());

    //     vm.prank(user2);
    //     amountOut = ammInstance.swapToken1ForToken0_WithSlipLock(1000 * 10**token1.decimals(), 500 * 10**token0.decimals(), 10);
    //     assertTrue(amountOut >= 500 * 10**token0.decimals());
    // }

    // function testSwapToken0ForToken1_WithSlipLock() external {
    //     vm.prank(user1);
    //     uint256 amountOut = ammInstance.swapToken0ForToken1_WithSlipLock(1000 * 10**token0.decimals(), 500 * 10**token1.decimals(), 10);
    //     assertTrue(amountOut >= 500 * 10**token1.decimals());

    //     vm.prank(user2);
    //     amountOut = ammInstance.swapToken0ForToken1_WithSlipLock(1000 * 10**token0.decimals(), 500 * 10**token1.decimals(), 10);
    //     assertTrue(amountOut >= 500 * 10**token1.decimals());
    // }
}

