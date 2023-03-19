// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//testnet Fanart Idol card back painted by @xizhiii
contract MyNFT is ERC721 {
    uint256 public tokenId = 0;
    address public owner;

    // using Strings for uint256;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        owner = msg.sender;
    }

    function mint() external {
        tokenId++;
        _safeMint(msg.sender, tokenId);
    }

    // function _baseURI() internal pure override returns (string memory) {
    //     return "";
    // }

    // function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    //     _requireMinted(_tokenId);

    //     string memory baseURI = _baseURI();
    //     return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _tokenId.toString(), ".json")) : "";
    // }
}