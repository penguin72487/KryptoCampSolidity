// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./erc20.sol";
import "./orderbook.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SetUp {
    testGaoDuckToken public tGD;
    OrderBook_ERC20_ETH public orderBook;

    constructor() {
        tGD = new testGaoDuckToken("testGaoDuckToken", "tGD");
        tGD.mint(msg.sender, 1000000000000);

        orderBook = new OrderBook_ERC20_ETH(tGD);
        tGD.approve(address(orderBook), type(uint256).max);
        tGD.approve(address(this), type(uint256).max);

        tGD.transferFrom(msg.sender,address(this), 100000000);
        orderBook.sellOrder(1000, 3);
    }
}
