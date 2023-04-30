// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
library BigInt {
    using SafeMath for uint256;
    struct bigint {
        uint256[] limbs;
    }
    uint256 constant BASE = 10**38;

    function add(bigint memory a, bigint memory b) public pure returns (bigint memory) {
        if(a.limbs.length < b.limbs.length) {
            bigint memory temp = a;
            a = b;
            b = temp;
        }

        bigint memory result;
        result.limbs = new uint256[](a.limbs.length+ 1);

        uint256 it=0;
        for(;it<b.limbs.length;it++) {
            result.limbs[it] = a.limbs[it] + b.limbs[it];
        }
        for(;it<a.limbs.length;it++) {
            result.limbs[it] = a.limbs[it];
        }
        for(uint256 i = 0; i < a.limbs.length; i++) {
            if(result.limbs[i] >= BASE) {
                result.limbs[i + 1] += result.limbs[i] / BASE;
                result.limbs[i] = result.limbs[i] % BASE; // Change this line
            }
        }
        if(result.limbs[a.limbs.length] == 0) {
            bigint memory result2;
            result2.limbs = new uint256[](a.limbs.length);
            for(uint256 i = 0; i < a.limbs.length; i++) {
                result2.limbs[i] = result.limbs[i];
            }
            return result2;
        }

        return result;
    }



     function subtract(bigint memory a, bigint memory b) internal pure returns (bigint memory) {
        require(a.limbs.length >= b.limbs.length, "Subtraction result would be negative");

        bigint memory result;
        result.limbs = new uint256[](a.limbs.length);

        for (uint256 i = 0; i < a.limbs.length; i++) {
            if (a.limbs[i] < b.limbs[i]) {
                a.limbs[i + 1] -= 1;
                a.limbs[i] += BASE;
            }
            result.limbs[i] = a.limbs[i] - b.limbs[i];
        }

        return result;
    }
    function karatsubaMultiply(bigint memory a, bigint memory b) internal pure returns (bigint memory) {
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
        bytes memory inputBytes = bytes(a);
        bigint memory result;
        result.limbs = new uint256[]((inputBytes.length + 38) / 39);
        bytes memory tempBytes = new bytes(39);
        
        for (uint256 i = 0; i < inputBytes.length; i++) {
            // Clear tempBytes when starting a new group of characters
            if (i % 39 == 0) {
                for (uint256 j = 0; j < 39; j++) {
                    tempBytes[j] = 0;
                }
            }

            tempBytes[i % 39] = inputBytes[inputBytes.length - i - 1];
            if (i % 39 == 38) {
                result.limbs[i / 39] = bytesToUint256(tempBytes);
            }
        }
        if (inputBytes.length % 39 != 0) {
            result.limbs[inputBytes.length / 39] = bytesToUint256(tempBytes);
        }
        return result;
    }

    function stringToUint256(string memory input) internal pure returns (uint256) {
        bytes memory inputBytes = bytes(input);
        uint256 output = 0;

        for (uint256 i = 0; i < inputBytes.length; i++) {
            uint8 currentChar = uint8(inputBytes[i]);
            
            // Check if the character is a valid digit (0-9)
            require(currentChar >= 48 && currentChar <= 57, "Invalid character in input string");

            // Subtract 48 to get the integer value of the digit (ASCII value of '0' is 48)
            uint8 digit = currentChar - 48;

            // Update the output with the new digit
            output = output * 10 + uint256(digit);
        }

        return output;
    }
    function bytesToUint256(bytes memory inputBytes) internal pure returns (uint256) {
        uint256 output = 0;

        for (uint256 i = 0; i < inputBytes.length; i++) {
            uint8 currentChar = uint8(inputBytes[i]);

            // Check if the character is a valid digit (0-9)
            if(currentChar >= 48 && currentChar <= 57)
            {
                // Subtract 48 to get the integer value of the digit (ASCII value of '0' is 48)
                uint8 digit = currentChar - 48;

                // Update the output with the new digit
                output = output * 10 + uint256(digit);
            }

        }

        return output;
    }


    function get_Decimal(BigInt.bigint memory a) internal pure returns (string memory) {
        string memory decimal = "";
        for (uint256 i = 0; i < a.limbs.length; i++) {
            if(a.limbs[i]==0)
            {
                break;
            }
            decimal = string(abi.encodePacked(decimal,Strings.toString(a.limbs[i])));
        }
        
        return reverse(decimal);
    }
    function reverse(string memory str) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        uint256 length = strBytes.length;

        for (uint256 i = 0; i < length / 2; i++) {
            bytes1 temp = strBytes[i];
            strBytes[i] = strBytes[length - 1 - i];
            strBytes[length - 1 - i] = temp;
        }

        return string(strBytes);
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
