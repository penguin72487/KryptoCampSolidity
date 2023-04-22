// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./bignum.sol";
import "./comput.sol";
import "@forge-std/Script.sol";
contract TestBigIntCalculator {
  BigIntCalculator calculator = new BigIntCalculator();

  function testAdd() public {
    BigInt.bigint memory a = BigInt.set_Uint256(1);
    BigInt.bigint memory b = BigInt.set_Uint256(2);
    BigInt.bigint memory c = calculator.add(a, b);
  }

  function testMultiply() public {
    BigInt.bigint memory a = BigInt.set_Uint256(123456789);
    BigInt.bigint memory b = BigInt.set_Uint256(987654321);
    BigInt.bigint memory c = calculator.multiply(a, b);
    console.log(c);

  }

  // Add more tests for subtract() and divide() here
}
