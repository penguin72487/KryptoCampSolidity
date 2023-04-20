// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library BigInt {
    struct bigint {
        uint256[] limbs;
    }

    function add(bigint memory a, bigint memory b) internal pure returns (bigint memory) {
        uint256 length = max(a.limbs.length, b.limbs.length);

        bigint memory result;
        result.limbs = new uint256[](length + 1);

        uint256 carry = 0;
        for (uint256 i = 0; i < length; i++) {
            uint256 sum = carry;
            if (i < a.limbs.length) {
                sum += a.limbs[i];
            }
            if (i < b.limbs.length) {
                sum += b.limbs[i];
            }

            result.limbs[i] = sum % (2**128);
            carry = sum / (2**128);
        }

        if (carry != 0) {
            result.limbs[length] = carry;
        }

        return result;
    }

    function multiply(bigint memory a, bigint memory b) internal pure returns (bigint memory) {
        bigint memory result;
        result.limbs = new uint256[](a.limbs.length + b.limbs.length);

        for (uint256 i = 0; i < a.limbs.length; i++) {
            uint256 carry = 0;
            for (uint256 j = 0; j < b.limbs.length; j++) {
                uint256 mul = a.limbs[i] * b.limbs[j] + carry + result.limbs[i + j];
                result.limbs[i + j] = mul % (2**128);
                carry = mul / (2**128);
            }
            result.limbs[i + b.limbs.length] = carry;
        }

        return result;
    }
        function subtract(bigint memory a, bigint memory b) internal pure returns (bigint memory) {
        require(a.limbs.length >= b.limbs.length, "Subtraction result would be negative");

        bigint memory result;
        result.limbs = new uint256[](a.limbs.length);

        int carry = 0;
        for (uint256 i = 0; i < a.limbs.length; i++) {
            int diff = int(a.limbs[i]) - carry;
            if (i < b.limbs.length) {
                diff -= int(b.limbs[i]);
            }
            if (diff < 0) {
                carry = 1;
                diff += int(2**128);
            } else {
                carry = 0;
            }

            result.limbs[i] = uint256(diff);
        }

        return result;
    }

    function divide(bigint memory a, bigint memory b) internal pure returns (bigint memory) {
        require(b.limbs.length > 0, "Division by zero");

        bigint memory quotient;
        quotient.limbs = new uint256[](a.limbs.length);
        bigint memory remainder = a;

        uint256 shift = (b.limbs.length - 1) * 128;
        b = leftShift(b, shift);

        for (int i = int(shift); i >= 0; i--) {
            if (compare(remainder, b) >= 0) {
                remainder = subtract(remainder, b);
                setBit(quotient, uint256(i));
            }
            b = rightShift(b, 1);
        }

        return quotient;
    }

    function leftShift(bigint memory a, uint256 n) internal pure returns (bigint memory) {
        bigint memory result;
        result.limbs = new uint256[](a.limbs.length + (n + 127) / 128);

        for (uint256 i = 0; i < a.limbs.length; i++) {
            result.limbs[i + n / 128] |= a.limbs[i] << (n % 128);
            if (i + n / 128 + 1 < result.limbs.length) {
                result.limbs[i + n / 128 + 1] |= a.limbs[i] >> (128 - n % 128);
            }
        }

        return result;
    }

    function rightShift(bigint memory a, uint256 n) internal pure returns (bigint memory) {
        bigint memory result;
        result.limbs = new uint256[](a.limbs.length);

        for (uint256 i = n / 128; i < a.limbs.length; i++) {
            result.limbs[i - n / 128] |= a.limbs[i] >> (n % 128);
            if (i > n / 128) {
                result.limbs[i - n / 128] |= a.limbs[i - 1] << (128 - n % 128);
            }
        }

        return result;
    }


    function max(uint256 a, uint256 b) private pure returns (uint256) {
        return a >= b ? a : b;
    }
    function compare(bigint memory a, bigint memory b) internal pure returns (int) {
        if (a.limbs.length > b.limbs.length) {
            return 1;
        } else if (a.limbs.length < b.limbs.length) {
            return -1;
        }

        for (int i = int(a.limbs.length) - 1; i >= 0; i--) {
            if (a.limbs[uint256(i)] > b.limbs[uint256(i)]) {
                return 1;
            } else if (a.limbs[uint256(i)] < b.limbs[uint256(i)]) {
                return -1;
            }
        }
        

        return 0;
    }
    function setBit(bigint memory a, uint256 position) internal pure {
        uint256 limbIndex = position / 128;
        uint256 bitIndex = position % 128;

        if (limbIndex >= a.limbs.length) {
            uint256[] memory newLimbs = new uint256[](limbIndex + 1);
            for (uint256 i = 0; i < a.limbs.length; i++) {
                newLimbs[i] = a.limbs[i];
            }
            a.limbs = newLimbs;
        }

        a.limbs[limbIndex] |= (1 << bitIndex);
    }


}

contract BigIntCalculator {
    using BigInt for BigInt.bigint;

    function add(BigInt.bigint calldata a, BigInt.bigint calldata b) external pure returns (BigInt.bigint memory) {
        return a.add(b);
    }

    function multiply(BigInt.bigint calldata a, BigInt.bigint calldata b) external pure returns (BigInt.bigint memory) {
        return a.multiply(b);
    }
}
