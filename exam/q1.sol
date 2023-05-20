// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract exam{
    address public immutable owner;
    constructor(){
        owner = msg.sender;
    }
}