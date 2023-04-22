// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Treap {
    struct Node {
        uint256 val;
        uint256 priority;
        uint256 left;
        uint256 right;
    }

    Node[] public nodes;
    uint256 private rootIndex;

    constructor() {
        nodes.push(Node(0, MAX_INT, 0, 0));
        rootIndex = 0;
    }

    function insert(adress ) public {
        rootIndex = _insert(rootIndex,node(uint256))
    }

    function erase(uint256 v) public {
        rootIndex = _erase(rootIndex, v);
    }

    function _leftRotate(uint256 t) private pure returns (uint256) {
        uint256 tmp = nodes[t].right;
        nodes[t].right = nodes[tmp].left;
        nodes[tmp].left = t;
        return tmp;
    }

    function _rightRotate(uint256 t) private pure returns (uint256) {
        uint256 tmp = nodes[t].left;
        nodes[t].left = nodes[tmp].right;
        nodes[tmp].right = t;
        return tmp;
    }

    function _insert(uint256 nowIndex, Node memory t) private returns (uint256) {
        if (nowIndex == 0) {
            nodes.push(t);
            return nodes.length - 1;
        }
        if (nodes[nowIndex].val < t.val) {
            nodes[nowIndex].right = _insert(nodes[nowIndex].right, t);
            if (nodes[nowIndex].priority < nodes[nodes[nowIndex].right].priority) {
                nowIndex = _leftRotate(nowIndex);
            }
        } else {
            nodes[nowIndex].left = _insert(nodes[nowIndex].left, t);
            if (nodes[nowIndex].priority < nodes[nodes[nowIndex].left].priority) {
                nowIndex = _rightRotate(nowIndex);
            }
        }
        return nowIndex;
    }

    function _erase(uint256 nowIndex, uint256 v) private returns (uint256) {
        if (nowIndex == 0) {
            return 0;
        }
        if (nodes[nowIndex].val == v) {
            uint256 ret = _merge(nodes[nowIndex].left, nodes[nowIndex].right);
            uint256 lastIndex = nodes.length - 1;

            if (nowIndex != lastIndex) {
                nodes[nowIndex] = nodes[lastIndex];

                uint256 parentIndex = _findParent(lastIndex);
                if (nodes[parentIndex].left == lastIndex) {
                    nodes[parentIndex].left = nowIndex;
                } else {
                    nodes[parentIndex].right = nowIndex;
                }

                if (nodes[nowIndex].left != 0) {
                    uint256 leftChildIndex = nodes[nowIndex].left;
                    nodes[leftChildIndex].left = nowIndex;
                }
                if (nodes[nowIndex].right != 0) {
                    uint256 rightChildIndex = nodes[nowIndex].right;
                    nodes[rightChildIndex].right = nowIndex;
                }
            }

            nodes.pop();
            return ret;
        } else if (nodes[nowIndex].val < v) {
            nodes[nowIndex].right = _erase(nodes[nowIndex].right, v);
        } else {
                        nodes[nowIndex].left = _erase(nodes[nowIndex].left, v);
        }
        return nowIndex;
    }

    function _merge(uint256 left, uint256 right) private pure returns (uint256) {
        if (left == 0 || right == 0) {
            return left == 0 ? right : left;
        }
        if (nodes[left].priority > nodes[right].priority) {
            nodes[left].right = _merge(nodes[left].right, right);
            return left;
        } else {
            nodes[right].left = _merge(left, nodes[right].left);
            return right;
        }
    }

    function _findParent(uint256 index) private view returns (uint256) {
        uint256 parentIndex = 0;
        uint256 currentNodeIndex = rootIndex;

        while (currentNodeIndex != index && currentNodeIndex != 0) {
            parentIndex = currentNodeIndex;

            if (nodes[currentNodeIndex].val < nodes[index].val) {
                currentNodeIndex = nodes[currentNodeIndex].right;
            } else {
                currentNodeIndex = nodes[currentNodeIndex].left;
            }
        }

        return parentIndex;
    }
    uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 keccak0 = uint256(keccak256(abi.encodePacked(address(0))));
    function random() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % MAX_INT;
    }
}

contract FanartNFT is ERC721 {
    uint256 public totle_Supply = 0;
    address public  creater;
    address[] public owner;
    uint256 public max_Supply=5;
    uint256 public mintPrice = 0 ether;
   address[] public whitelist = [
    0x7A4D6c296B28460cda81Fb584234A15Fc105e182,
    0xB7Ef6435a61AAD311748AC5116C67e8d0888aD19,
    0xCbB4a73328ce05745c248447AD7199F6D4925D87,
    0x168Ba19d17e6F38c41260D6A46Bdeeb4D503a177
    ];
    treap public treap_Whitelist;
    // using Strings for uint256;
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        creater = msg.sender;
        whitelist.push(creater);
        treap_Whitelist = new treap();
        for(uint256 i = 0; i < whitelist.length; i++) {
            treap_Whitelist.insert(whitelist[i]);
        }
    }

    // constructor(string memory _name, string memory _symbol,address[] memory _whitelist) ERC721(_name, _symbol) {
    //     creater = msg.sender;
    //     for(uint256 i=0;i<_whitelist.length;i++)
    //     {
    //         treap_Whitelist.insert(_whitelist[i]);
    //     }
    // }


    
    function mint() public payable {
        require(totle_Supply<max_Supply);
        require(msg.value >= mintPrice, "Insufficient payment.");
        require(treap_Whitelist.verify(msg.sender),"You are not in the whitelist");
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

//TXT BEOMGYU
//TXT Bear
//5
//0x877Dd9205617085dD9B04a92CEaF83eB380678BA
//0x681A514c5AF6583AC827cb91a4a5a34DBaC6ef4F
//0x7969aC088c9bE45755AEb23efB2073A5620fC60f
//0xf3A446e1966e8f92711BB450Bc64D01F9EF4aff7
//0xf85Dd6Fc6ED85099408A411e300B321647E3Cc1c


/* whitelist
[0x7A4D6c296B28460cda81Fb584234A15Fc105e182,0xB7Ef6435a61AAD311748AC5116C67e8d0888aD19,0xCbB4a73328ce05745c248447AD7199F6D4925D87,0x168Ba19d17e6F38c41260D6A46Bdeeb4D503a177];
*/