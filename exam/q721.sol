// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 {
    uint256 public totalSupply;

    constructor () ERC721 ("MyNFT", "MNFT") {
        totalSupply = 0;
    }

    function mint(address _to) public {
        _mint(_to, totalSupply);
        totalSupply += 1;
    }
}
