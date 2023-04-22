// SPDX-License-Identifier: MIT
//ERC20 0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95
pragma solidity ^0.8.19;
import "./heap.sol";
import "./erc20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract OrderBook_ERC20_ETH {   // sell tGD get ETH buy tGD pay ETH
    //enum OrderType { Buy, Sell }
    MaxHeap private buyHeap;
    MinHeap private sellHeap;
    //IERC20(0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95);
    IERC20 tGD;
    constructor(IERC20 _tGD) {
        tGD = _tGD;
        buyHeap = new MaxHeap();
        sellHeap = new MinHeap();
    }
    function getSellPrice() public view returns (uint256) {
        return sellHeap.top().price;
    }
    function getBuyPrice() public view returns (uint256) {
        return buyHeap.top().price;
    }
    function getBuyTop() public view returns (address, uint256, uint256, uint256) {
        return (buyHeap.top().trader, buyHeap.top().amount, buyHeap.top().price, buyHeap.top().timestamp);
    }
    function getSellTop() public view returns (address, uint256, uint256, uint256) {
        return (sellHeap.top().trader, sellHeap.top().amount, sellHeap.top().price, sellHeap.top().timestamp);
    }
    function buyOrder(uint256 _amount, uint256 price) public payable{
        uint256 amount = _amount;
        require(msg.value >= amount* buyHeap.top().price);

        if(buyHeap.top().price >= price) {

            buyHeap.push(MaxHeap.Order(msg.sender, amount, price, block.timestamp));
        }
        if(sellHeap.top().price<=price )
        {
            //match
            if(sellHeap.top().price == price) {
                while(sellHeap.top().price == price) {
                    if(sellHeap.top().amount > amount) {
                        
                        address payable receiver = payable(sellHeap.top().trader);
                        receiver.transfer(amount);

                        sellHeap.top().amount -= amount;
                        amount = 0;
                        break;
                    } else {
                        address payable receiver = payable(sellHeap.top().trader);
                        receiver.transfer(sellHeap.top().amount);
                        amount -= sellHeap.top().amount;
                        sellHeap.pop();
                    }
                }
            }
            tGD.transferFrom(msg.sender, address(this), _amount-amount);
            if(amount > 0) {
                buyHeap.push(MaxHeap.Order(msg.sender, amount, price, block.timestamp));
            }

        }
        else{
            buyHeap.push(MaxHeap.Order(msg.sender, amount, price, block.timestamp));
        }
    }
    function buyOrder(uint256 _amount) public payable
    {
        uint256 amount = _amount;
        require(msg.value >= amount* buyHeap.top().price);
        while(amount > 0) {
            if(buyHeap.top().amount > amount) {
                address payable receiver = payable(sellHeap.top().trader);
                receiver.transfer(amount);
                buyHeap.top().amount -= amount;
                amount = 0;
                break;
            } else {
                address payable receiver = payable(sellHeap.top().trader);
                receiver.transfer(sellHeap.top().amount);
                amount -= buyHeap.top().amount;
                buyHeap.pop();
            }
        }
    }
    function sellOrder(uint256 _amount) public 
    {
        uint256 amount = _amount;
        require(tGD.balanceOf(msg.sender) >= _amount);
        while(amount > 0) {
            if(sellHeap.top().amount > amount) {
                tGD.transferFrom(msg.sender, buyHeap.top().trader, _amount-amount);
                sellHeap.top().amount -= amount;
                amount = 0;
                break;
            } else {
                tGD.transferFrom(msg.sender, buyHeap.top().trader, buyHeap.top().amount);
                amount -= sellHeap.top().amount;
                sellHeap.pop();
            }
        }
    }
    function sellOrder(uint256 _amount, uint256 price) public {
        uint256 amount = _amount;
        tGD.approve(msg.sender, amount);
        require(tGD.balanceOf(msg.sender) >= _amount, string(abi.encodePacked(addressToString(msg.sender), " not enough token")));
        if(sellHeap.top().price <= price) {
            tGD.transferFrom(msg.sender, address(this), _amount);
            sellHeap.push(MinHeap.Order(msg.sender, amount, price, block.timestamp));
            return;
        }
        if(buyHeap.top().price>=price )
        {
            //match
            if(buyHeap.top().price >= price) {
                while(buyHeap.top().price >= price) {
                    if(buyHeap.top().amount > amount) {
                        tGD.transferFrom(msg.sender, buyHeap.top().trader, _amount-amount);
                        buyHeap.top().amount -= amount;
                        amount = 0;
                        break;
                    } else {
                        tGD.transferFrom(msg.sender, buyHeap.top().trader, buyHeap.top().amount);
                        amount -= buyHeap.top().amount;
                        buyHeap.pop();
                    }
                }
            }
            address payable receiver = payable(msg.sender);
            receiver.transfer(_amount-amount);
            if(amount > 0) {
                sellHeap.push(MinHeap.Order(msg.sender, amount, price, block.timestamp));
            }

        }
        else{
            sellHeap.push(MinHeap.Order(msg.sender, amount, price, block.timestamp));
        }
    }
    function addressToString(address _address) internal pure returns (string memory) {
        bytes32 result = bytes32(uint256(uint160(_address)));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(result[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(result[i + 12] & 0x0f)];
        }
        return string(str);
    }


    
}
