// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "../src/bignum.sol";
import "forge-std/console.sol";
import "forge-std/Vm.sol";
import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "forge-std/console2.sol";

contract CounterScript is Script {
    using BigInt for BigInt.bigint;

    event LogString(BigInt.bigint);
    event LogString(string);

    constructor() {
    }

    function setUp() public {}

    function run() public {
        // testAdd();
        // testSubtract();
        // testkaratsubaMultiply();
        // emit LogString("ok ka");
        // testDivide();
        // emit LogString("ok di");
        // testMultiply();
        // emit LogString("ok mu");
        // testMultiply();
        // emit LogString("ok mu");
        testLargeNumbers();
        emit LogString("ok ln");
    }
    function testLargeNumbers() internal {
        string memory largeNumber1 = "115792089237316195423570985008687907853269984665640564039457584007913129639936";
        string memory largeNumber2 = "57896044618658097711785492504343953926634992332820282019728792003956564819968";
        
        BigInt.bigint memory a = BigInt.set_String(largeNumber1);
        BigInt.bigint memory b = BigInt.set_String(largeNumber2);
        BigInt.bigint memory c = a.add(b);
        //BigInt.bigint memory d = a.karatsubaMultiply(b);
        emit LogString(c.get_Decimal());
        //emit LogString(d.get_Decimal());
    }

    function testkaratsubaMultiply() internal
    {
        BigInt.bigint memory a = BigInt.set_Uint256(123456789);
        BigInt.bigint memory b = BigInt.set_Uint256(987654321);
        BigInt.bigint memory c = a.karatsubaMultiply(b);
        emit LogString(c.get_Decimal());
    }

    function testAdd() internal {
        BigInt.bigint memory a = BigInt.set_Uint256(123456789);
        BigInt.bigint memory b = BigInt.set_Uint256(987654321);
        BigInt.bigint memory c = a.add(b);
        emit LogString(c.get_Decimal());

    }

    function testMultiply() internal {
        BigInt.bigint memory a = BigInt.set_Uint256(123456789);
        BigInt.bigint memory b = BigInt.set_Uint256(987654321);
        BigInt.bigint memory c = a.multiply(b);
        emit LogString(c.get_Decimal());

    }

    function testSubtract() internal {
        BigInt.bigint memory a = BigInt.set_Uint256(987654321);
        BigInt.bigint memory b = BigInt.set_Uint256(123456789);
        BigInt.bigint memory c = a.subtract(b);
        emit LogString(c.get_Decimal());

    }

    function testDivide() internal {
        BigInt.bigint memory a = BigInt.set_Uint256(987654321);
        BigInt.bigint memory b = BigInt.set_Uint256(123456789);
        BigInt.bigint memory c = a.divide(b);
        emit LogString(c.get_Decimal());

    }
}
