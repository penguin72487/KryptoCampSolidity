// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.18;
// import "../src/simpleamm.sol";
// import "../src/erc20.sol";
// import "forge-std/Test.sol";
// import "forge-std/console.sol";
// import "forge-std/Vm.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

// contract TestSimpleAMM {
//     using Address for address payable;
//     event LogString(string);
//     event LogUint(uint256);
//     testGaoDuckToken public tGD;
//     AMM public ammInstance;
//     address public user1;
//     address public user2;
//     function setUp() public{
//         tGD = new testGaoDuckToken("testGaoDuck", "tGD");
//         ammInstance = new AMM(address(tGD));

//         user1 = address(0x1234567890123456789012345678901234567890);
//         user2 = address(0x0987654321098765432109876543210987654321);

//         tGD.mint(user1, 2000);
//         tGD.mint(user2, 2000);
//         vm.prank(user1);
//         tGD.approve(address(ammInstance), 1000*1e18);
//         vm.prank(user2);
//         tGD.approve(address(ammInstance), 1000*1e18);
//     }
//     function run() public {
        
//         testAddLiquidity();
//         testSwap();
//     }

//     function testAddLiquidity() public {
//         tGD.transferFrom(user1, address(ammInstance), 1000);
//         tGD.transferFrom(user2, address(ammInstance), 1000);

//         uint256 sharesUser1 = ammInstance.addLiquidity{value: 1 ether}(1000);
//         uint256 sharesUser2 = ammInstance.addLiquidity{value: 1 ether}(1000);

//         uint256 expectedShares = ammInstance.totalSupply();
//     }

//     function testSwap() public {
        
//         testAddLiquidity();

//         tGD.approve(address(ammInstance), 10);
//         tGD.transferFrom(msg.sender, user1, 10);

//         uint256 ethAmountBeforeSwap = address(user1).balance;

//         uint256 ethAmountOut = ammInstance.swapTokenForETH(10);
//         uint256 ethAmountAfterSwap = address(user1).balance;
//     }
// }
