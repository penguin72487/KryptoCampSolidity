// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
// token0 T0 8 0xafea7BB86Fb50A68db5bD443e0607aab59DF0750
// token1 T1 18 0x4aF233EF89022f4618a3879C7133Ac24d039feee

contract AMM {
    address public immutable developer;

    ERC20 public immutable token0;
    ERC20 public immutable token1;

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    uint256 public immutable fee;

    constructor(address _token0, address _token1, uint256 _fee) {
        require(_fee>0 &&_fee <= 100, "fee > 10%");
        developer = msg.sender;
        token0 = ERC20(_token0);
        token1 = ERC20(_token1);
        fee = _fee;
        //check ERC20 interface
        token0.name();
        token0.symbol();
        token0.decimals();
        token1.name();
        token1.symbol();
        token1.decimals();
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

    function swapToken1ForToken0(uint256 _amountIn) public returns (uint256 amountOut) { // T0/T1
        require(_amountIn > 0, "Insufficient input amount");
        token1.transferFrom(msg.sender, address(this), _amountIn);
        amountOut = getInToken1PredictOutputToken0(_amountIn);
        require(amountOut > 0, "Insufficient output amount");
        uint256 feeToDeveloper = _amountIn * fee * totalSupply / (reserve0 * 2000);
        _mint(developer, feeToDeveloper); // 50% of the profit to developer

        token0.transfer(msg.sender, amountOut);

        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    function swapToken0ForToken1(uint256 _amountIn) public returns (uint256 amountOut) { // T1/T0
        require(_amountIn > 0, "Insufficient input amount");
        token0.transferFrom(msg.sender, address(this), _amountIn);
        amountOut = getInToken0PredictOutputToken1(_amountIn);
        require(amountOut > 0, "Insufficient output amount");
        uint256 feeToDeveloper = _amountIn * fee * totalSupply / (reserve0 * 2000);
        _mint(developer, feeToDeveloper); // 50% of the profit to developer

        token1.transfer(msg.sender, amountOut);

        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    function swapToken1ForToken0_WithSlipLock(
        uint256 _amountIn,
        uint256 _forwardOutput,
        uint256 _slipLock
    ) public returns (uint256 amountOut) {
        require(_amountIn > 0, "Insufficient input amount");
        token1.transferFrom(msg.sender, address(this), _amountIn);
        amountOut = getInToken1PredictOutputToken0(_amountIn);
        require(amountOut > 0, "Insufficient output amount");
        require(amountOut >= (_forwardOutput * (1000 - _slipLock) / 1000), "SlipLock");
        uint256 feeToDeveloper = _amountIn * fee * totalSupply / (reserve0 * 2000);
        _mint(developer, feeToDeveloper); // 50% of the profit to developer

        token0.transfer(msg.sender, amountOut);
        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }
    function swapToken0ForToken1_WithSlipLock(
        uint256 _amountIn,
        uint256 _forwardOutput,
        uint256 _slipLock
    ) public returns (uint256 amountOut) {
        require(_amountIn > 0, "Insufficient input amount");
        token0.transferFrom(msg.sender, address(this), _amountIn);
        amountOut = getInToken0PredictOutputToken1(_amountIn);
        require(amountOut > 0, "Insufficient output amount");
        require(amountOut >= (_forwardOutput * (1000 - _slipLock) / 1000), "SlipLock");
        uint256 feeToDeveloper = _amountIn * fee * totalSupply / (reserve0 * 2000);
        _mint(developer, feeToDeveloper); // 50% of the profit to developer

        token1.transfer(msg.sender, amountOut);

        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    function addLiquidity(uint256 _amount0, uint256 _amount1) external returns (uint256 shares) {
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        if (reserve0 > 0 || reserve1 > 0) {
            require(reserve0 * _amount1*(1000-fee) <= reserve1 * _amount0*1000&&reserve0 * _amount1*1000 >= reserve1 * _amount0*(1000-fee), "x / y != dx / dy +- fee%");
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

        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    function removeAllLiquidity() external returns (uint256 amount0, uint256 amount1) {
        return _removeLiquidity(msg.sender, balanceOf[msg.sender]);
    }

    function removeLiquidity(uint256 _shares) external returns (uint256 amount0, uint256 amount1) {
        require(_shares <= balanceOf[msg.sender], "Insufficient balance");
        return _removeLiquidity(msg.sender, _shares);
    }

    function _removeLiquidity(address _user, uint256 _shares) internal returns (uint256 amount0, uint256 amount1) {
        amount0 = (_shares * reserve0) / totalSupply;
        amount1 = (_shares * reserve1) / totalSupply;
        require(amount0 > 0 && amount1 > 0, "amount0 or amount1 = 0");

        _burn(_user, _shares);
        token0.transfer(_user, amount0);
        token1.transfer(_user, amount1);
        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    function myShares() public view returns (uint256) {
        return balanceOf[msg.sender];
    }
    function sharesOf(address _user) public view returns (uint256) {
        return balanceOf[_user];
    }
    function _sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function getToken0Price() public view returns (uint256) {
        require(reserve0 > 0 && reserve1 > 0, "Invalid reserves");
        uint256 decimals1 = ERC20(address(token1)).decimals();
        return (reserve0 * (10**decimals1)) / (reserve1);
    }
    function getToken1Price() public view returns (uint256) {
        require(reserve0 > 0 && reserve1 > 0, "Invalid reserves");
        uint256 decimals0 = ERC20(address(token0)).decimals();
        return (reserve1 * (10**decimals0)) / (reserve0);
    }

    function getInToken0PredictOutputToken1(uint256 _amount) public view returns (uint256) {
        require(reserve0 > 0 && reserve1 > 0 && _amount > 0, "Invalid reserves");
        uint256 amountInWithFee = (_amount * (1000-fee)) / 1000;
        return (reserve1 * amountInWithFee) / (reserve0 + amountInWithFee);
    }

    function getInToken1PredictOutputToken0(uint256 _amount) public view returns (uint256) {
        require(reserve0 > 0 && reserve1 > 0 && _amount > 0, "Invalid reserves");
        uint256 amountInWithFee = (_amount * (1000-fee)) / 1000;
        return (reserve0 * amountInWithFee) / (reserve1 + amountInWithFee);
    }
    function getInToken1OutputToken0LiquidityAmount(uint256 _amount) public view returns (uint256) {
        require(reserve0 > 0 && reserve1 > 0 && _amount>0,string(abi.encodePacked("Invalid", token1.symbol(),"reserves")));
        return reserve0 * _amount / reserve1;
    }
    function getInToken0OutputToken1LiquidityAmount(uint256 _amount) public view returns (uint256) {
        require(reserve0 > 0 && reserve1 > 0 && _amount>0,string(abi.encodePacked("Invalid", token0.symbol(),"reserves")));
        return reserve1 * _amount / reserve0;
    }

}