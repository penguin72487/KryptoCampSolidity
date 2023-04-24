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
        emit LogString("ok op");
        testLargeNumbers();
        emit LogString("ok ln");
    }
    function testLargeNumbers() internal {
        string memory largeNumber1 = "115792089237316195423570985008687907853269984665640564039457584007913129639936";
        string memory largeNumber2 = "57896044618658097711785492504343953926634992332820282019728792003956564819968";
        string memory largeNumber3 = "340282366920938463463374607431768211455"; // 2^128 - 1
        string memory largeNumber4 = "680564733841876926926749214863536422911"; // 2^128 * 2
        string memory largeNumber5 = "1020847100762815390390123822295304633817"; // 2^128 * 3

        BigInt.bigint memory a = BigInt.set_String(largeNumber1);
        BigInt.bigint memory b = BigInt.set_String(largeNumber2);
        BigInt.bigint memory c = BigInt.set_String(largeNumber3);
        BigInt.bigint memory d = BigInt.set_String(largeNumber4);
        BigInt.bigint memory e = BigInt.set_String(largeNumber5);

        BigInt.bigint memory sum_ab = a.add(b);
        BigInt.bigint memory sum_ac = a.add(c);
        BigInt.bigint memory sum_ad = a.add(d);
        BigInt.bigint memory sum_ae = a.add(e);

        compareResultsAndLog(sum_ab.get_Decimal(), "173685088023092593180556387713399684179005976003378441555863461847475295659904", "sum_ab");
        compareResultsAndLog(sum_ac.get_Decimal(), "115792089237316195423570985008687907853269984665640564039457584007913129980219", "sum_ac");
        compareResultsAndLog(sum_ad.get_Decimal(), "115792089237316195423570985008687907853269984665640564039457584007913130320675", "sum_ad");
        compareResultsAndLog(sum_ae.get_Decimal(), "115792089237316195423570985008687907853269984665640564039457584007913130661131", "sum_ae");
    }

    function compareResultsAndLog(string memory result, string memory expected, string memory testName) internal {
        bool isCorrect = keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked(expected));
        emit LogString(string(abi.encodePacked(testName, isCorrect ? " is correct!" : " is incorrect!")));
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
