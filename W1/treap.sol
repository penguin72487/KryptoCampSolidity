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

    constructor() {
        nodes.push(Node(0, MAX_INT, 0, 0));
    }

    function insert(address _whitelist_user) public {
        nodes[0].right = _insert(nodes[0].right, Node(uint256(keccak256(abi.encodePacked(_whitelist_user))),random(),0,0));
    }

    function erase(uint256 v) public {
        nodes[0].right = _erase(nodes[0].right, v);
    }
    function verify(address _whitelist_user) public view returns (bool) {
        return _verify(nodes[0].right, uint256(keccak256(abi.encodePacked(_whitelist_user))));
    }
    function _verify(uint256 nowIndex, uint256 v) private view returns (bool) {
        if (nowIndex == 0) {
            return false;
        }
        if (nodes[nowIndex].val == v) {
            return true;
        } else if (nodes[nowIndex].val < v) {
            return _verify(nodes[nowIndex].right, v);
        } else {
            return _verify(nodes[nowIndex].left, v);
        }
    }

    function _leftRotate(uint256 t) internal returns (uint256) {
        uint256 tmp = nodes[t].right;
        nodes[t].right = nodes[tmp].left;
        nodes[tmp].left = t;
        return tmp;
    }

    function _rightRotate(uint256 t) internal returns (uint256) {
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

    function _erase(uint256 nowIndex, uint256 v) internal returns (uint256) {
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

    function _merge(uint256 left, uint256 right) internal returns (uint256) {
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
        uint256 currentNodeIndex = nodes[0].right;

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
    function print() public view returns (uint256[] memory) {
        uint256[] memory ret = new uint256[](nodes.length*2);
        for(uint256 i = 0; i < nodes.length; i+=2) {
            ret[i] = nodes[i].left;
            ret[i+1] = nodes[i].right;
        }
        return ret;
    }

    uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 keccak0 = uint256(keccak256(abi.encodePacked(address(0))));
    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.number , msg.sender))) % MAX_INT;
    }
}