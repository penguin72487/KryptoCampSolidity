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

    event LogBigInt(BigInt.bigint);

    BigIntCalculator public calculator;

    constructor() {
        calculator = new BigIntCalculator();
    }

    function setUp() public {}

    function run() public {
        testAdd();
        testMultiply();
        testSubtract();
        testDivide();
    }

    function testAdd() internal {
        BigInt.bigint memory a = BigInt.set_Uint256(123456789);
        BigInt.bigint memory b = BigInt.set_Uint256(987654321);
        BigInt.bigint memory c = calculator.add(a, b);
        emit LogBigInt(c);
    }

    function testMultiply() internal {
        BigInt.bigint memory a = BigInt.set_Uint256(123456789);
        BigInt.bigint memory b = BigInt.set_Uint256(987654321);
        BigInt.bigint memory c = calculator.multiply(a, b);
        emit LogBigInt(c);
    }

    function testSubtract() internal {
        BigInt.bigint memory a = BigInt.set_Uint256(987654321);
        BigInt.bigint memory b = BigInt.set_Uint256(123456789);
        BigInt.bigint memory c = calculator.subtract(a, b);
        emit LogBigInt(c);
    }

    function testDivide() internal {
        BigInt.bigint memory a = BigInt.set_Uint256(987654321);
        BigInt.bigint memory b = BigInt.set_Uint256(123456789);
        BigInt.bigint memory c = calculator.divide(a, b);
        emit LogBigInt(c);
    }
}
