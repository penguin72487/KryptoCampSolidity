// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "./bignum.sol";

// contract BigIntExample {
//     using BigInt for BigInt.bigint;

//     function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
//         return (a + b - 1) / b;
//     }

//     function calculate() public pure returns (BigInt.bigint memory) {
//         // Create the bigint 10^87
//         BigInt.bigint memory baseTen = BigInt.bigint({
//             limbs: new uint256[](1)
//         });
//         baseTen.limbs[0] = 10**77;

//         // Create the bigint 2^1234
//         uint256 limbsLength = 1 + ceilDiv(1234, 128);
//         BigInt.bigint memory baseTwo = BigInt.bigint({
//             limbs: new uint256[](limbsLength)
//         });
//         baseTwo.setBit(1234);

//         // Calculate the result: 10^87 * 2^1234
//         BigInt.bigint memory result = baseTen.multiply(baseTwo);
//         return result;
//     }
// }
