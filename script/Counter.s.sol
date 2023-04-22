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

    BigIntCalculator public calculator;

    constructor() {
    }

    function setUp() public {}

    function run() public {
        testAdd();
        testSubtract();
        testkaratsubaMultiply();
        emit LogString("ok ka");
        testDivide();
        emit LogString("ok di");
        //testMultiply();
        emit LogString("ok mu");
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
