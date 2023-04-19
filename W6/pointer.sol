// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18 <0.9.0;

contract Node {
    uint256 public index;
    uint256 public value;

    constructor(uint256 _index, uint256 _value) {
        index = _index;
        value = _value;
    }

    function delete_uint256() public {
        index = 0;
        value = type(uint256).max;
    }

    function setIndex(uint256 _index) public {
        index = _index;
    }

    function setValue(uint256 _value) public {
        value = _value;
    }
}

contract Pointer {
    Node[] public pointer;
    uint256[] public nullPointer;

    constructor() {
        pointer.push(new Node(0, type(uint256).max));
    }

    function new_uint256(uint256 value) public returns (uint256) {
        uint256 p;
        if (nullPointer.length > 0) {
            p = nullPointer[nullPointer.length - 1];
            nullPointer.pop();
            pointer[p].setIndex(pointer.length); // =
            pointer[p].setValue(value); // =
        } else {
            p = pointer.length;
            pointer.push(new Node(p, value));
        }
        return p;
    }
    function delete_uint256(uint256 p) public {
        require(p < pointer.length, "out of range");
        if(p == pointer.length - 1) {
            pointer.pop();
        } else {
            pointer[p].delete_uint256();
            nullPointer.push(p);
        }
    }
    
}
