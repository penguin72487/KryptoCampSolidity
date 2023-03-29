// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "./heap.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract OrderBook_tGD_ETH {   // sell tGD get ETH buy tGD pay ETH
    //enum OrderType { Buy, Sell }
    MinHeap private buyHeap;
    MaxHeap private sellHeap;

    IERC20 tGD = IERC20(0xd9145CCE52D386f254917e481eB44e9943F39138);
    constructor() {
        buyHeap = new MinHeap();
        sellHeap = new MaxHeap();
    }
    function getSellPrice() public view returns (uint256) {
        return sellHeap.top().price;
    }
    function getBuyPrice() public view returns (uint256) {
        return buyHeap.top().price;
    }
    function buyOrder(uint256 amount, uint256 price) public payable{
        require(msg.value == amount*(10**18) * price);

        if(buyHeap.top().price >= price) {
            buyHeap.push(MinHeap.Order(msg.sender, amount, price, block.timestamp));
        }
        if(sellHeap.top().price<=price )
        {
            //match
            if(sellHeap.top().price == price) {
                while(sellHeap.top().price == price) {
                    if(sellHeap.top().amount > amount) {
                        tGD.transferFrom(address(this), msg.sender, amount);
                        address payable receiver = payable(sellHeap.top().trader);
                        receiver.transfer(amount);

                        sellHeap.top().amount -= amount;
                        amount = 0;
                        break;
                    } else {
                        amount -= sellHeap.top().amount;
                        sellHeap.pop();
                    }
                }
            }
            if(amount > 0) {
                buyHeap.push(MinHeap.Order(msg.sender, amount, price, block.timestamp));
            }

        }
    }
    // function buyOrder(uint256 amount) public
    // {
    //     while(amount > 0) {
    //         if(buyHeap.top().amount > amount) {
    //             buyHeap.top().amount -= amount;
    //             amount = 0;
    //             break;
    //         } else {
    //             amount -= buyHeap.top().amount;
    //             buyHeap.pop();
    //         }
    //     }
    // }
    // function sellOrder(uint256 amount) public 
    // {
    //     while(amount > 0) {
    //         if(sellHeap.top().amount > amount) {
    //             sellHeap.top().amount -= amount;
    //             amount = 0;
    //             break;
    //         } else {
    //             amount -= sellHeap.top().amount;
    //             sellHeap.pop();
    //         }
    //     }
    // }
    function sellOrder(uint256 amount, uint256 price) public {

        if(sellHeap.top().price <= price) {
            sellHeap.push(MaxHeap.Order(msg.sender, amount, price, block.timestamp));
        }
        if(buyHeap.top().price>=price )
        {
            //match
            if(buyHeap.top().price == price) {
                while(buyHeap.top().price == price) {
                    if(buyHeap.top().amount > amount) {
                        buyHeap.top().amount -= amount;
                        amount = 0;
                        break;
                    } else {
                        amount -= buyHeap.top().amount;
                        buyHeap.pop();
                    }
                }
            }
            if(amount > 0) {
                sellHeap.push(MaxHeap.Order(msg.sender, amount, price, block.timestamp));
            }

        }
    }
    
}
