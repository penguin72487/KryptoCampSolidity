// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/utils/Strings.sol";
library BigInt {
    struct bigint {
        uint256[] limbs;
    }

    function add(bigint memory a, bigint memory b) internal pure returns (bigint memory) {
    uint256 length = max(a.limbs.length, b.limbs.length);

    bigint memory result;
    result.limbs = new uint256[](length);

    uint256 carry = 0;
    for(uint256 )

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

        // Remove leading zero limbs
        uint256 lastIndex = result.limbs.length - 1;
        while (lastIndex > 0 && result.limbs[lastIndex] == 0) {
            lastIndex--;
        }
        if (lastIndex < result.limbs.length - 1) {
            uint256[] memory newLimbs = new uint256[](lastIndex + 1);
            for (uint256 i = 0; i <= lastIndex; i++) {
                newLimbs[i] = result.limbs[i];
            }
            result.limbs = newLimbs;
        }

        return result;
    }
    function karatsubaMultiply(bigint memory a, bigint memory b) public pure returns (bigint memory) {
    uint256 lenA = a.limbs.length;
    uint256 lenB = b.limbs.length;

    if (lenA == 1 && lenB == 1) {
        bigint memory presult;
        presult.limbs = new uint256[](1);
        presult.limbs[0] = a.limbs[0] * b.limbs[0];
        return presult;
    }

    uint256 half = (max(lenA, lenB) + 1) / 2;

    bigint memory aLow = slice(a, 0, half);
    bigint memory aHigh = slice(a, half, lenA);
    bigint memory bLow = slice(b, 0, half);
    bigint memory bHigh = slice(b, half, lenB);

    bigint memory p0 = karatsubaMultiply(aLow, bLow);
    bigint memory p1 = karatsubaMultiply(aHigh, bHigh);
    bigint memory p2 = karatsubaMultiply(add(aLow, aHigh), add(bLow, bHigh));
    bigint memory p3 = subtract(subtract(p2, p1), p0);

    bigint memory result = add(add(leftShift(p1, 2 * half * 128), leftShift(p3, half * 128)), p0);
    return result;
}

function slice(bigint memory a, uint256 start, uint256 end) internal pure returns (bigint memory) {
    uint256 length = end - start;
    bigint memory result;
    result.limbs = new uint256[](length);

    for (uint256 i = 0; i < length && start + i < a.limbs.length; i++) {
        result.limbs[i] = a.limbs[start + i];
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
        return a > b ? a : b;
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
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
    function set_Uint256(uint256 a) internal pure returns (bigint memory) {
        bigint memory result;
        result.limbs = new uint256[](1);
        result.limbs[0] = a;
        return result;
    }
    function set_String(string memory a) internal pure returns (bigint memory) {
        bytes memory input = bytes(a);
        require(input.length > 0, "Input string must not be empty");

        uint256 base = 2**128;
        uint256 groupSize = 1;
        uint256 maxGroupValue = base;

        bigint memory result;
        uint256[] memory tempLimbs = new uint256[]((input.length + groupSize - 1) / groupSize);
        uint256 tempIndex = 0;
        uint256 groupValue = 0;
        uint256 groupDigits = 0;

        for (uint256 i = 0; i < input.length; i++) {
            uint8 digit = uint8(input[i]) - 48; // Convert the ASCII value to the corresponding integer
            require(digit < 10, "Input string contains invalid characters");

            groupValue = groupValue * 10 + digit;
            groupDigits++;

            if (groupDigits == groupSize) {
                tempLimbs[tempIndex] = groupValue;
                tempIndex++;
                groupValue = 0;
                groupDigits = 0;
            }
        }

        if (groupDigits > 0) {
            tempLimbs[tempIndex] = groupValue;
        }

        result.limbs = new uint256[](tempIndex + 1);
        for (uint256 i = 0; i <= tempIndex; i++) {
            bigint memory tempBigint = set_Uint256(tempLimbs[i]);
            bigint memory baseBigint = set_Uint256(maxGroupValue);
            for (uint256 j = 0; j < tempIndex - i; j++) {
                tempBigint = multiply(tempBigint, baseBigint);
            }
            result = add(result, tempBigint);
        }

        return result;
    
    }
    function get_Decimal(BigInt.bigint memory a) internal pure returns (string memory) {
        uint256 base = 2**128;
        uint256 groupSize = 1;
        uint256 maxGroupValue = base;

        bigint memory temp = a;
        string memory decimal = "";

        while (BigInt.compare(temp, BigInt.set_Uint256(0)) > 0) {
            bigint memory remainder = BigInt.mod(temp, maxGroupValue);
            uint256 groupValue = remainder.limbs[0];
            string memory groupString = Strings.toString(groupValue);

            if (BigInt.compare(temp, BigInt.set_Uint256(maxGroupValue)) >= 0) {
                temp = BigInt.divide(temp, BigInt.set_Uint256(maxGroupValue));
                decimal = string(abi.encodePacked(groupString, decimal));
            } else {
                decimal = string(abi.encodePacked(Strings.toString(groupValue), decimal));
                break;
            }
        }

        return decimal;
    }

    function mod(bigint memory a, uint256 b) internal pure returns (bigint memory) {
    require(b > 0, "Modulus must be greater than zero");
    bigint memory result;

    uint256 remainder = 0;
    for (int i = int(a.limbs.length) - 1; i >= 0; i--) {
        uint256 temp = (remainder * (2**128)) + a.limbs[uint256(i)];
        remainder = temp % b;
    }

    result.limbs = new uint256[](1);
    result.limbs[0] = remainder;
    return result;
}
}
