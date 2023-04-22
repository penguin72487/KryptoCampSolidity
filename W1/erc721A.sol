// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721A.sol";

contract FanartNFT is ERC721A {
    uint256 public totle_Supply = 0;
    address public creater;
    address[] public owner;
    uint256 public max_Supply=5;
    uint256 public mintPrice = 0.01 ether;

    constructor(string memory _name, string memory _symbol) ERC721A(_name, _symbol) {
        creater = msg.sender;
    }

    function mint() public payable {
        require(totle_Supply<max_Supply);
        require(msg.value >= mintPrice, "Insufficient payment.");
        _safeMint(msg.sender, totle_Supply);
        owner.push(msg.sender);
        totle_Supply++;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://gateway.pinata.cloud/ipfs/QmZtd6uks6g92fhzoadBy8iVn3Lmdhg8AeycS1KUQXCsM4";
    }
    
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        _requireMinted(_tokenId);

        string memory baseURI = _baseURI();
        string memory tokenIdStr = Strings.toString(_tokenId);
        return string(abi.encodePacked(baseURI, "/", tokenIdStr, "/", tokenIdStr, ".json"));
    }

    
    function ownerOf(uint256 _tokenId) public view override returns (address){
        if(_tokenId < max_Supply)
        {
            return owner[_tokenId];
        }
        else {
            return address(0);
        }
    }
    
    function withdraw() public {
        require(msg.sender == creater, "Only the contract creator can call this function");
        payable(msg.sender).transfer(address(this).balance);
    }
}
