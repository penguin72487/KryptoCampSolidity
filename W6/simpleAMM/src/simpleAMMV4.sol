// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
//goerli 0xae6B0f75b55fa4c90b2768e3157b7000241A41c5 merge 0x4a9C121080f6D9250Fc0143f41B595fD172E31bf
// V1 0xf60440f93a677AB6968E1Fd10cf8a6cE61941131
// V2 0x8b175c421E9307F0365dd37bc32Dda5df95C4946
// V3 0x3ea585565c490232b0379C7D3C3A9fC3fA5C9c0C
// V4  0x6D81EE8B003422Ee9d1255aceA42386eCBD20a60 merge 0x540d7E428D5207B30EE03F2551Cbb5751D3c7569
  /**
   * @title ContractName
   * @dev ContractDescription
   * @custom:dev-run-script ../script/tAMM.js
   */

import "./erc20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract AMM {
    //using safeMath for uint256;
    IERC20 public immutable token;
    address public constant ETH_ADDRESS = address(0);

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function _mint(address _to, uint256 _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint256 _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint256 _reserve0, uint256 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function swap(uint256 _amountIn) public payable returns (uint256 amountOut) {
        require(msg.value == _amountIn, "ETH amount mismatch");

        uint256 amountInWithFee = (_amountIn * 997) / 1000;
        amountOut = (reserve1 * amountInWithFee) / (reserve0 + amountInWithFee);

        token.transfer(msg.sender, amountOut);

        _update(address(this).balance, token.balanceOf(address(this)));
    }
    // function _swapWithOutFee(uint256 _amountIn) internal payable returns (uint256 amountOut) {
    //     require(msg.value == _amountIn, "ETH amount mismatch");
    //     amountOut = reserve1 / reserve0 ;

    //     token.transfer(msg.sender, amountOut);

    //     _update(address(this).balance, token.balanceOf(address(this)));
    // }
    function swapTokenForETH(uint256 _amountIn) public returns (uint256 amountOut) {
        uint256 amountInWithFee = (_amountIn * 997) / 1000;

        amountOut = (reserve0 * amountInWithFee) / (reserve1 + amountInWithFee);
        require(amountOut > 0, "Insufficient output amount");

        token.transferFrom(msg.sender, address(this), _amountIn);
        payable(msg.sender).transfer(amountOut);

        _update(address(this).balance - amountOut, token.balanceOf(address(this)));
    }
    // function _swapTokenForETHWithOutFee(uint256 _amountIn) internal returns (uint256 amountOut) {
    //     amountOut = reserve0 / reserve1;
    //     require(amountOut > 0, "Insufficient output amount");

    //     token.transferFrom(msg.sender, address(this), _amountIn);
    //     payable(msg.sender).transfer(amountOut);

    //     _update(address(this).balance - amountOut, token.balanceOf(address(this)));
    // }

    function addLiquidity(uint256 _amount1) external payable returns (uint256 shares) {
        //token.approve(address(this), _amount1);
        token.transferFrom(msg.sender, address(this), _amount1);

        uint256 _amount0 = msg.value;

        if (reserve0 > 0 || reserve1 > 0) {
            if (reserve0 * _amount1 != reserve1 * _amount0) {
                // Calculate the required amount of tokens to make the ratio equal
                uint256 requiredAmount1 = (reserve1 * _amount0) / reserve0;
                
                // Swap the excess tokens for ETH without fee
                if (_amount1 > requiredAmount1) {
                    uint256 excessAmount1 = _amount1 - requiredAmount1;
                    _amount0 += swapTokenForETH(excessAmount1);

                // Swap the excess ETH for tokens without fee
                } else {
                    uint256 excessAmount0 = _amount0 - requiredAmount1 * reserve0 / reserve1;
                    _amount1 += swap(excessAmount0);
                }

                // Update the _amount1 to the required amount
                _amount1 = requiredAmount1;
            }
        }

        if (totalSupply == 0) {
            shares = _sqrt(_amount0 * _amount1);
        } else {
            shares = Math.min(
                (_amount0 * totalSupply) / reserve0,
                (_amount1 * totalSupply) / reserve1
            );
        }
        require(shares > 0, "shares = 0");
        _mint(msg.sender, shares);

        _update(address(this).balance, token.balanceOf(address(this)));
    }

    function removeAllLiquidity(address _user) external returns (uint256 amount0, uint256 amount1) {
        return _removeLiquidity(_user,balanceOf[_user]);
    }
    function removeLiquidity(uint256 _shares) external returns (uint256 amount0, uint256 amount1) {
        require(_shares <= balanceOf[msg.sender], "Insufficient balance");
        return _removeLiquidity(msg.sender, _shares);
    }

    function removeLiquidity(address _user, uint256 _shares) external returns (uint256 amount0, uint256 amount1) {
        require(_shares <= balanceOf[_user], "Insufficient balance");
        return _removeLiquidity(_user, _shares);
    }
    function _removeLiquidity(address _user, uint256 _shares) internal returns (uint256 amount0, uint256 amount1) {
        amount0 = (_shares * address(this).balance) / totalSupply;
        amount1 = (_shares * token.balanceOf(address(this))) / totalSupply;
        require(amount0 > 0 && amount1 > 0, "amount0 or amount1 = 0");

        _burn(_user, _shares);
        _update(address(this).balance - amount0, token.balanceOf(address(this)) - amount1);

        payable(_user).transfer(amount0);
        token.transfer(_user, amount1);
    }
    function my_shars() public view returns(uint256){
        return balanceOf[msg.sender];
    }
    function sharesOf(address _user) public view returns(uint256){
        return balanceOf[_user];
    }

    function _sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }
    function getETHPrice() public view returns (uint256) {
        require(reserve0 + reserve1 > 0, "Invalid reserves");
        return (reserve1 * 10**18) / reserve0;
    }
    function getERCPrice() public view returns (uint256) {
        require(reserve0 + reserve1 > 0, "Invalid reserves");
        return (reserve0 * 10**18) / reserve1;
    }
    function getPricePredicttGD(uint256 _amount) public view returns (uint256) {
        require(reserve0 + reserve1 > 0, "Invalid reserves");
        uint256 amountInWithFee=(_amount * 997) / 1000;
        return (reserve1 * amountInWithFee) / (reserve0 + amountInWithFee);
    }
    function getPricePredictETH(uint256 _amount) public view returns (uint256) {
        require(reserve0 + reserve1 > 0, "Invalid reserves");
        uint256 amountInWithFee=(_amount * 997) / 1000;
        return (reserve0 * amountInWithFee) / (reserve1 + amountInWithFee);
    }
    function calculateSlippage(uint256 amountIn) public view returns (uint256) {
        require(amountIn > 0, "Invalid input amount");

        uint256 amountInWithFee = (amountIn * 997) / 1000;
        uint256 amountOut = (reserve1 * amountInWithFee) / (reserve0 + amountInWithFee);
        require(amountOut > 0, "Invalid output amount");

        // Calculate the price without any slippage
        uint256 noSlippagePrice = getERCPrice();

        // Calculate the expected output amount without any slippage
        uint256 expectedAmountOut = (amountIn * noSlippagePrice) / 10**18;

        // Calculate the slippage percentage
        uint256 slippage;
        if (amountOut > expectedAmountOut) {
            slippage = ((amountOut - expectedAmountOut) * 1000) / expectedAmountOut;
        } else {
            slippage = ((expectedAmountOut - amountOut) * 1000) / expectedAmountOut;
        }

        // Clamp the slippage value between 1 and 1000 (0.1% and 100%)
        slippage = _min(slippage, 1000);

        return slippage;
    }




}