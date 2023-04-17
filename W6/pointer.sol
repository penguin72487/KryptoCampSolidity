// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18 <0.9.0;

contract Pointer{
    uint256[] public pointer; // index is pointer, *p is value, pointer[0] is nullptr
    uint256[] public nullPointer;
    constructor() {
        pointer.push(0);
    }
    function new_uint256(uint256 value) public returns (uint256){
        if (nullPointer.length == 0){
            pointer.push(value);
            return pointer.length - 1;
        }
        else{
            uint256 p = nullPointer[nullPointer.length - 1];
            nullPointer.pop();
            pointer[p] = value;
            return p;
        }
    }
    function delete_uint256(uint256 p) public{
        require((p != 0&&p<pointer.length), "Cannot delete nullptr");
        if(p==pointer.length-1){
            pointer.pop();
        }
        else{
            pointer[p] = 0;
            nullPointer.push(p);
        }
    }
}