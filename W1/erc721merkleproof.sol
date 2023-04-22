// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
//// testnet Fanart, BEOMGYU painted by @xizhiii 
contract FanartNFT is ERC721 {
    uint256 public totle_Supply = 0;
    address public  creater;
    address[] public owner;
    uint256 public max_Supply=5;
    uint256 public mintPrice = 0.01 ether;
    bytes32 public merkleRoot;
    // using Strings for uint256;

    // using Strings for uint256;
    constructor(string memory _name, string memory _symbol, bytes32 _merkleRoot) ERC721(_name, _symbol) {
        creater = msg.sender;
        merkleRoot = _merkleRoot;
    }

    function mint(bytes32[] calldata _proof) public payable {
        require(totle_Supply<max_Supply, "Max supply reached.");
        require(msg.value >= mintPrice, "Insufficient payment.");
        require(_verify(msg.sender, _proof), "Invalid Merkle proof.");
        _safeMint(msg.sender, totle_Supply);
        owner.push(msg.sender);
        totle_Supply++;
    }

    function _verify(address _account, bytes32[] calldata _proof) internal view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(_account));
        return MerkleProof.verify(_proof, merkleRoot, leaf);
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

    function ownerOf(uint256 _tokenId) public view override returns (address) {
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

//TXT BEOMGYU
//TXT Bear
//5
//0x877Dd9205617085dD9B04a92CEaF83eB380678BA
//0x681A514c5AF6583AC827cb91a4a5a34DBaC6ef4F
//0x7969aC088c9bE45755AEb23efB2073A5620fC60f
//0xf3A446e1966e8f92711BB450Bc64D01F9EF4aff7
//0xf85Dd6Fc6ED85099408A411e300B321647E3Cc1c





/*whitelist
0x7A4D6c296B28460cda81Fb584234A15Fc105e182
0xB7Ef6435a61AAD311748AC5116C67e8d0888aD19
0xCbB4a73328ce05745c248447AD7199F6D4925D87
0x168Ba19d17e6F38c41260D6A46Bdeeb4D503a177
*/