// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18 <0.9.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../W1/erc20.sol";

contract Pool {
    uint256 public ethTotal;
    uint256 public tokenTotal;
    address public creator;
    ERC20 public token = ERC20(0xae6B0f75b55fa4c90b2768e3157b7000241A41c5);
    AggregatorV3Interface internal ethPriceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);

    constructor() payable {
        ethTotal = msg.value; // Store the amount of ETH sent while deploying the contract
        tokenTotal = 1_000_000 * 10 ** token.decimals(); // Total supply of 1,000,000 tokens with decimals
        creator = msg.sender;
    }

    function getLatestEthPrice() public view returns (uint256) {
        (, int256 answer,,,) = ethPriceFeed.latestRoundData();
        return uint256(answer);
    }

    function buyEthWithTokens(uint256 tokensToSpend) public {
        require(token.balanceOf(msg.sender) >= tokensToSpend, "Not enough tokens to spend");

        uint256 ethPrice = getLatestEthPrice();
        uint256 ethToBuy = (tokensToSpend * 1e18) / ethPrice;
        require(address(this).balance >= ethToBuy, "Not enough ETH in the pool");

        ethTotal -= ethToBuy;
        tokenTotal += tokensToSpend;

        token.transferFrom(msg.sender, creator, tokensToSpend);
        payable(msg.sender).transfer(ethToBuy);
    }

    function sellEthForTokens() public payable {
        uint256 ethPrice = getLatestEthPrice();
        uint256 tokensToReturn = (msg.value * ethPrice) / 1e18;
        require(token.balanceOf(creator) >= tokensToReturn, "Not enough tokens in the pool");

        ethTotal += msg.value;
        tokenTotal -= tokensToReturn;

        token.transferFrom(creator, msg.sender, tokensToReturn);
    }

    function withdraw() public {
        require(msg.sender == creator, "Only the contract creator can call this function");
        payable(msg.sender).transfer(address(this).balance);
    }
}
