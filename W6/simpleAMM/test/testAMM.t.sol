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
    event logString(string);
    event logUint(uint256);
    event log(string indexed key, uint256 value);
        function _sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }


    function setUp() external {
        tGD = new testGaoDuckToken("testGaoDuck", "tGD");
        ammInstance = new AMM(address(tGD));
        
        user1 = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        user2 = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

        tGD.mint(user1, 38000);
        tGD.mint(user2, 38000);

        // Transfer Ether from the current account to user1
        payable(user1).transfer(50 ether);
        payable(user2).transfer(50 ether);

        vm.prank(user1);
        tGD.approve(address(ammInstance), 4000 * 1e18);
        //ammInstance.addLiquidity{value: 1 ether}(1 * 1e18);
        vm.prank(user2);
        tGD.approve(address(ammInstance), 4000 * 1e18);
    }



    // function testExample() external {
    //     uint256 initialBalanceUser1 = tGD.balanceOf(user1);
    //     uint256 initialBalanceUser2 = tGD.balanceOf(user2);
    //     uint256 initialEthBalanceUser1 = address(user1).balance;
    //     uint256 initialEthBalanceUser2 = address(user2).balance;

    //     // User 1 adds liquidity
    //     vm.prank(user1);
    //     ammInstance.addLiquidity{value: 10 ether}(1000 * 1e18);

    //     uint256 lpBalanceUser1 = ammInstance.balanceOf(user1);
    //     assertTrue(lpBalanceUser1 > 0, "User 1 should have received LP tokens");

    //     // User 2 swaps ETH for tGD
    //     uint256 amountIn = 1 ether;
    //     vm.prank(user2);
    //     uint256 amountOut = ammInstance.swap{value: amountIn}(amountIn);

    //     assertTrue(amountOut > 0, "User 2 should have received tGD tokens");
    //     assertEq(tGD.balanceOf(user2), initialBalanceUser2 + amountOut, "User 2 tGD balance mismatch");
    //     assertEq(address(user2).balance, initialEthBalanceUser2 - amountIn, "User 2 ETH balance mismatch");

    //     // User 1 removes liquidity
    //     vm.prank(user1);
    //     uint256 beforetGDBalanceUser1 = tGD.balanceOf(user1);
    //     uint256 beforeEthBalanceUser1 = address(user1).balance;
    //     (uint256 amount0, uint256 amount1) = ammInstance.removeAllLiquidity(user1);

    //     assertTrue(amount0 > 0 && amount1 > 0, "User 1 should have received ETH and tGD");
    //     assertEq(tGD.balanceOf(user1), beforetGDBalanceUser1 + amount1, "User 1 tGD balance mismatch");
    //     assertEq(address(user1).balance, beforeEthBalanceUser1 + amount0, "User 1 ETH balance mismatch");
    // }
    function testaddLiquidity() external {
        
        vm.prank(user1);
        tGD.approve(address(ammInstance), 10000 * 1e18);
        //ammInstance.addLiquidity{value: 1 ether}(1 * 1e18);
        vm.prank(user2);
        tGD.approve(address(ammInstance), 10000 * 1e18);
        // Add liquidity for user1
        vm.prank(user1);
        uint256 amount1 = 1000 * 1e18;
        uint256 amount2 = 0.5 ether;
        uint256 shares1 = ammInstance.addLiquidity{value: amount2}(amount1);

        // Check liquidity shares
        assertEq(shares1, _sqrt(amount1 * amount2), "Invalid liquidity shares");

        // Add liquidity for user2
        vm.prank(user2);
        amount1 = 1500 * 1e18;
        amount2 = 0.75 ether;
        uint256 shares2 = ammInstance.addLiquidity{value: amount2}(amount1);

        // Check liquidity shares
        assertEq(shares2, Math.min((amount1 * shares1) / ammInstance.reserve0(), (amount2 * shares1) / ammInstance.reserve1()), "Invalid liquidity shares");

        // Swap tokens to make the ratio uneven
        // emit logUint(tGD.balanceOf(user2));
        // emit logUint(tGD.allowance(user2, address(ammInstance)));
        // uint256 token1Amount = 500 * 1e18;
        // uint256 token2Amount = ammInstance.swapTokenForETH(token1Amount);
        // assertEq(token2Amount, 0.25 ether, "Invalid token2 amount after swap");

        // Add liquidity again for user1 with the uneven ratio
        vm.prank(user1);
        amount1 = 500 * 1e18;
        amount2 = 0.25 ether;
        uint256 shares3 = ammInstance.addLiquidity{value: amount2}(amount1);

        // Check liquidity shares
        uint256 requiredAmount1 = (ammInstance.reserve1() * amount2) / ammInstance.reserve0();
        uint256 expectedShares3 = Math.min((requiredAmount1 * shares1) / ammInstance.reserve1(), shares1);
        assertEq(shares3, expectedShares3, "Invalid liquidity shares after swap");

        // Check that the token ratio is even
        uint256 expectedReserve0 = (shares1 * tGD.balanceOf(address(this))) / _sqrt(amount1 * amount2);
        assertEq(ammInstance.reserve0(), expectedReserve0, "Invalid reserve0 after swap");
        assertEq(ammInstance.reserve1(), tGD.balanceOf(address(this)), "Invalid reserve1 after swap");
    }





    // function testInvalidSwap() external {
    //     uint256 initialEthBalanceUser1 = address(user1).balance;
    //     emit logString("initialEthBalanceUser1");
    //     emit logUint(initialEthBalanceUser1);
    //     uint256 amountIn = initialEthBalanceUser1+2 ether;

    //     // Try swapping more ETH than available in the reserves
    //     vm.prank(user1);
    //     bool errorThrown = false;
    //     try ammInstance.swap{value: amountIn}(amountIn) {
    //     } catch {
    //         errorThrown = true;
    //     }
    //     assertTrue(errorThrown, "Expected error on invalid swap");
    //     assertEq(address(user1).balance, initialEthBalanceUser1, "User 1 ETH balance should not change");
    // }

    // function testInvalidSwapTokenForETH() external {
    //     uint256 initialEthBalanceUser1 = address(user1).balance;
    //     uint256 initialTokenBalanceUser1 = tGD.balanceOf(user1);
    //     uint256 amountIn = 2000 * 1e18;

    //     // Try swapping more tokens than available in the reserves
    //     vm.prank(user1);
    //     bool errorThrown = false;
    //     try ammInstance.swapTokenForETH(amountIn) {
    //     } catch {
    //         errorThrown = true;
    //     }
    //     assertTrue(errorThrown, "Expected error on invalid token swap");
    //     assertEq(tGD.balanceOf(user1), initialTokenBalanceUser1, "User 1 token balance should not change");
    //     assertEq(address(user1).balance, initialEthBalanceUser1, "User 1 ETH balance should not change");
    // }

    // function testInvalidAddLiquidity() external {
    //     uint256 initialEthBalanceUser1 = address(user1).balance;
    //     uint256 initialTokenBalanceUser1 = tGD.balanceOf(user1);

    //     // Try adding liquidity with unequal ETH/token ratios
    //     vm.prank(user1);
    //     bool errorThrown = false;
    //     try ammInstance.addLiquidity{value: initialEthBalanceUser1+5 ether}(1000 * 1e18) {
    //     } catch {
    //         errorThrown = true;
    //     }
    //     assertTrue(errorThrown, "Expected error on invalid liquidity addition");
    //     assertEq(tGD.balanceOf(user1), initialTokenBalanceUser1, "User 1 token balance should not change");
    //     assertEq(address(user1).balance, initialEthBalanceUser1, "User 1 ETH balance should not change");
    // }

    // function testInvalidRemoveLiquidity() external {
    //     // Add liquidity first
    //     vm.prank(user1);
    //     ammInstance.addLiquidity{value: 10 ether}(1000 * 1e18);

    //     uint256 lpBalanceUser1 = ammInstance.balanceOf(user1);
    //     uint256 invalidShares = lpBalanceUser1 + 1;

    //     // Try removing more liquidity than available
    //     bool errorThrown = false;
    //     try ammInstance.removeLiquidity(invalidShares) {
    //     } catch {
    //         errorThrown = true;
    //     }
    //     assertTrue(errorThrown, "Expected error on invalid liquidity removal");
    // }


}