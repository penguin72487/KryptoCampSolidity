// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

contract HelloWorld {

    event HelloEvent(string _message, address _sender);

    function renderHelloWorld () public returns (string memory) {
        emit HelloEvent("Hello world", msg.sender);
        return "Hello world";
    }

}
