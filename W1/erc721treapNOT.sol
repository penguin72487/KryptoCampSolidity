// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18 <0.9.0;
//import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract treap {

    struct Node {
        uint256 index;
        uint256 priority;
        uint256 size;
        uint256 val;
        uint256 sum;
        uint256 left; 
        uint256 right;
    }
    Node[] private root;
    uint256 size = 0;// count All node unless node0
    constructor() {
        root.push(Node(0,MAX_INT, 0, uint256(keccak256(abi.encodePacked(address(0)))), 
        uint256(keccak256(abi.encodePacked(address(0),address(0),address(0)))), 0, 0));
    }
    function insert(address _whitelist_user) public{
        
        size++;// for abs index
        root.push(Node(size, random(), 0, uint256(keccak256(abi.encodePacked(_whitelist_user))),
        0, 0, 0));
        root[size].sum = uint256(keccak256(abi.encodePacked(get_Sum(root[size].left),root[size].val,get_Sum(root[size].right))));
        root[0].right = merge(0, size);
    }
    
    
    


    function get_Sum(uint256 _now) public view returns (uint256){
        return _now!=0 ?root[_now].sum:keccak0;
    }

    function get_Size(uint256 _now) public view returns (uint256){
        return _now!=0 ?root[_now].size:0;
    }
    function pull(uint256 _now) public {
        if(_now!=0){
            root[_now].sum = uint256(keccak256(abi.encodePacked(get_Sum(root[_now].left),root[_now].val,get_Sum(root[_now].right))));
            root[_now].size = 1 + get_Size(root[_now].left) + get_Size(root[_now].right);
        }
    }
    function merge(uint256 a, uint256 b) public returns (uint256) {
        if(a==0||b==0) 
        {
            return a!=0?a:b;
        }
        if(root[a].priority > root[b].priority){
            root[a].right = merge(root[a].right, b);
            pull(a);
            return a;
        }
        else{
            root[b].left = merge(a, root[b].left);
            pull(b);
            return b;
        }
    }
    function splitByIndex(uint256 _now, uint256 _index) public returns (uint256, uint256) { // for modify one point
        if(_now==0) return (0,0);
        if(root[_now].index<=_index){
            (uint256 a, uint256 b) = splitByIndex(root[_now].right, _index);
            root[_now].right = a;
            pull(_now);
            return (_now, b);
        }
        else{
            (uint256 a, uint256 b) = splitByIndex(root[_now].left, _index);
            root[_now].left = b;
            pull(_now);
            return (a, _now);
        }
    }
    // function splitBySize(uint256 _now, uint256 _size) public returns (uint256, uint256) { // for range query
    //     if(_now==0) return (0,0);
    //     if(get_Size(root[_now].left)+1>=_size){ //  +1????
    //         (uint256 a, uint256 b) = splitBySize(root[_now].left, _size);
    //         root[_now].left = b;
    //         pull(_now);
    //         return (a, _now);
    //     }
    //     else{
    //         (uint256 a, uint256 b) = splitBySize(root[_now].right, _size-get_Size(root[_now].left)-1);
    //         root[_now].right = a;
    //         pull(_now);
    //         return (_now, b);
    //     }
    // }

    uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 keccak0 = uint256(keccak256(abi.encodePacked(address(0))));
    function random() public view returns (uint256) {
        bytes32 blockHash = blockhash(block.number - 1);
        return uint256(blockHash);
    }



}




// contract FanartNFT is ERC721 {
//     uint256 public totle_Supply = 0;
//     address public  creater;
//     address[] public owner;
//     uint256 public max_Supply=5;
//     uint256 public mintPrice = 0.01 ether;
//     // using Strings for uint256;

//     constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
//         creater = msg.sender;
//     }


    
//     function mint() public payable {
//         require(totle_Supply<max_Supply);
//         require(msg.value >= mintPrice, "Insufficient payment.");
//         _safeMint(msg.sender, totle_Supply);
//         owner.push(msg.sender);
//         totle_Supply++;
//     }

//     function _baseURI() internal pure override returns (string memory) {
//         return "https://gateway.pinata.cloud/ipfs/QmZtd6uks6g92fhzoadBy8iVn3Lmdhg8AeycS1KUQXCsM4";
//     }
//     function tokenURI(uint256 _tokenId) public view override returns (string memory) {
//     _requireMinted(_tokenId);

//     string memory baseURI = _baseURI();
//     string memory tokenIdStr = Strings.toString(_tokenId);
//     return string(abi.encodePacked(baseURI, "/", tokenIdStr, "/", tokenIdStr, ".json"));
//     }


//     function ownerOf(uint256 _tokenId) public view override returns (address){
//         if(_tokenId < max_Supply)
//         {
//             return owner[_tokenId];
//         }
//         else {
//             return address(0);
//         }
//     }
//     function withdraw() public {
//         require(msg.sender == creater, "Only the contract creator can call this function");
//         payable(msg.sender).transfer(address(this).balance);
//     }

// }

//TXT BEOMGYU
//TXT Bear
//5
//0x877Dd9205617085dD9B04a92CEaF83eB380678BA
//0x681A514c5AF6583AC827cb91a4a5a34DBaC6ef4F
//0x7969aC088c9bE45755AEb23efB2073A5620fC60f
//0xf3A446e1966e8f92711BB450Bc64D01F9EF4aff7
//0xf85Dd6Fc6ED85099408A411e300B321647E3Cc1c