// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/simpleAMMV5.sol";
import "../src/teamToken.sol";

contract TestSimpleAMMTest is Test {
    AMM public ammInstance;
    teamToken public ERC20;
    address public user1;
    address public user2;
    event logString(string);
    event logUint(uint256);
    event log(string indexed key, uint256 value);



    function setUp() external {
        ERC20 = new teamToken("testGaoDuck", "ERC20", 18, 10000000);
        ammInstance = new AMM(address(ERC20));
        
        user1 = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        user2 = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

        ERC20.mint(user1, 2000*1e18);
        ERC20.mint(user2, 2000*1e18);

        // Transfer Ether from the current account to user1
        payable(user1).transfer(50 ether);
        payable(user2).transfer(50 ether);

        vm.prank(user1);
        ERC20.approve(address(ammInstance), 1000 * 1e18);
        vm.prank(user2);
        ERC20.approve(address(ammInstance), 1000 * 1e18);
    }



    function testExample() external {
        uint256 initialBalanceUser1 = ERC20.balanceOf(user1);
        uint256 initialBalanceUser2 = ERC20.balanceOf(user2);
        uint256 initialEthBalanceUser1 = address(user1).balance;
        uint256 initialEthBalanceUser2 = address(user2).balance;

        // User 1 adds liquidity
        vm.prank(user1);
        ammInstance.addLiquidity{value: 10 ether}(1000 * 1e18);

        uint256 lpBalanceUser1 = ammInstance.balanceOf(user1);
        assertTrue(lpBalanceUser1 > 0, "User 1 should have received LP tokens");

        // User 2 swaps ETH for ERC20
        uint256 amountIn = 1 ether;
        vm.prank(user2);
        uint256 amountOut = ammInstance.swap{value: amountIn}(amountIn);

        assertTrue(amountOut > 0, "User 2 should have received ERC20 tokens");
        assertEq(ERC20.balanceOf(user2), initialBalanceUser2 + amountOut, "User 2 ERC20 balance mismatch");
        assertEq(address(user2).balance, initialEthBalanceUser2 - amountIn, "User 2 ETH balance mismatch");

        // User 1 removes liquidity
        vm.prank(user1);
        uint256 beforeERC20BalanceUser1 = ERC20.balanceOf(user1);
        uint256 beforeEthBalanceUser1 = address(user1).balance;
        (uint256 amount0, uint256 amount1) = ammInstance.removeAllLiquidity(user1);

        assertTrue(amount0 > 0 && amount1 > 0, "User 1 should have received ETH and ERC20");
        assertEq(ERC20.balanceOf(user1), beforeERC20BalanceUser1 + amount1, "User 1 ERC20 balance mismatch");
        assertEq(address(user1).balance, beforeEthBalanceUser1 + amount0, "User 1 ETH balance mismatch");
    }


    function testInvalidSwap() external {
        uint256 initialEthBalanceUser1 = address(user1).balance;
        emit logString("initialEthBalanceUser1");
        emit logUint(initialEthBalanceUser1);
        uint256 amountIn = initialEthBalanceUser1+2 ether;

        // Try swapping more ETH than available in the reserves
        vm.prank(user1);
        bool errorThrown = false;
        try ammInstance.swap{value: amountIn}(amountIn) {
        } catch {
            errorThrown = true;
        }
        assertTrue(errorThrown, "Expected error on invalid swap");
        assertEq(address(user1).balance, initialEthBalanceUser1, "User 1 ETH balance should not change");
    }

    function testInvalidSwapTokenForETH() external {
        uint256 initialEthBalanceUser1 = address(user1).balance;
        uint256 initialTokenBalanceUser1 = ERC20.balanceOf(user1);
        uint256 amountIn = 2000 * 1e18;

        // Try swapping more tokens than available in the reserves
        vm.prank(user1);
        bool errorThrown = false;
        try ammInstance.swapTokenForETH(amountIn) {
        } catch {
            errorThrown = true;
        }
        assertTrue(errorThrown, "Expected error on invalid token swap");
        assertEq(ERC20.balanceOf(user1), initialTokenBalanceUser1, "User 1 token balance should not change");
        assertEq(address(user1).balance, initialEthBalanceUser1, "User 1 ETH balance should not change");
    }

    function testInvalidAddLiquidity() external {
        uint256 initialEthBalanceUser1 = address(user1).balance;
        uint256 initialTokenBalanceUser1 = ERC20.balanceOf(user1);

        // Try adding liquidity with unequal ETH/token ratios
        vm.prank(user1);
        bool errorThrown = false;
        try ammInstance.addLiquidity{value: initialEthBalanceUser1+5 ether}(1000 * 1e18) {
        } catch {
            errorThrown = true;
        }
        assertTrue(errorThrown, "Expected error on invalid liquidity addition");
        assertEq(ERC20.balanceOf(user1), initialTokenBalanceUser1, "User 1 token balance should not change");
        assertEq(address(user1).balance, initialEthBalanceUser1, "User 1 ETH balance should not change");
    }

    function testInvalidRemoveLiquidity() external {
        // Add liquidity first
        vm.prank(user1);
        ammInstance.addLiquidity{value: 10 ether}(1000 * 1e18);

        uint256 lpBalanceUser1 = ammInstance.balanceOf(user1);
        uint256 invalidShares = lpBalanceUser1 + 1;

        // Try removing more liquidity than available
        bool errorThrown = false;
        try ammInstance.removeLiquidity(invalidShares) {
        } catch {
            errorThrown = true;
        }
        assertTrue(errorThrown, "Expected error on invalid liquidity removal");
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

        uint256 initialBalance = ERC20.balanceOf(user2);
        uint256 amountOut;

        // User2 swaps ETH for tokens
        vm.prank(user2);
        amountOut = ammInstance.swap{value: 0.5 ether}(0.5 ether);
        assertGt(ERC20.balanceOf(user2), initialBalance);
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
        uint256 initialTokenBalance = ERC20.balanceOf(user1);
        uint256 amount0;
        uint256 amount1;

        // User1 removes liquidity
        vm.prank(user1);
        (amount0, amount1) = ammInstance.removeLiquidity(shares);

        assertEq(ammInstance.balanceOf(user1), 0);
        assertGt(address(user1).balance, initialEthBalance);
        assertGt(ERC20.balanceOf(user1), initialTokenBalance);
    }
    function test_removeAllLiquidity() public {
        // User1 adds liquidity
        test_addLiquidity();

        uint256 initialEthBalance = address(user1).balance;
        uint256 initialTokenBalance = ERC20.balanceOf(user1);

        uint256 amount0;
        uint256 amount1;

        // User1 removes all liquidity
        vm.prank(user1);
        (amount0, amount1) = ammInstance.removeAllLiquidity(user1);

        assertEq(ammInstance.balanceOf(user1), 0);
        assertGt(address(user1).balance, initialEthBalance);
        assertGt(ERC20.balanceOf(user1), initialTokenBalance);
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