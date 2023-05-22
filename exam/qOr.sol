// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18 <0.9.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Pool {
    AggregatorV3Interface internal ethPriceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
    uint256 public price;
    constructor() {
        price = getLatestEthPrice();
    }
    function getLatestEthPrice() public view returns (uint256) {
        (, int256 answer,,,) = ethPriceFeed.latestRoundData();
        return uint256(answer);
    }

}
