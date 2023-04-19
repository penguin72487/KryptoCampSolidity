// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
//goerli 0xae6B0f75b55fa4c90b2768e3157b7000241A41c5
// V1 0xf60440f93a677AB6968E1Fd10cf8a6cE61941131
// V2 0x8b175c421E9307F0365dd37bc32Dda5df95C4946
import "./erc20.sol";
contract AMM {
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

    function swap(uint256 _amountIn) external payable returns (uint256 amountOut) {
        require(msg.value == _amountIn, "ETH amount mismatch");

        uint256 amountInWithFee = (_amountIn * 997) / 1000;
        amountOut = (reserve1 * amountInWithFee) / (reserve0 + amountInWithFee);

        token.transfer(msg.sender, amountOut);

        _update(address(this).balance, token.balanceOf(address(this)));
    }

    function addLiquidity(uint256 _amount1) external payable returns (uint256 shares) {
        token.transferFrom(msg.sender, address(this), _amount1);

        uint256 _amount0 = msg.value;

        if (reserve0 > 0 || reserve1 > 0) {
            require(reserve0 * _amount1 == reserve1 * _amount0, "x / y != dx / dy");
        }

        if (totalSupply == 0) {
            shares = _sqrt(_amount0 * _amount1);
        } else {
            shares = _min(
                (_amount0 * totalSupply) / reserve0,
                (_amount1 * totalSupply) / reserve1
            );
        }
        require(shares > 0, "shares = 0");
        _mint(msg.sender, shares);

        _update(address(this).balance, token.balanceOf(address(this)));
    }

    function removeLiquidity(uint256 _shares) external returns (uint256 amount0, uint256 amount1) {
        amount0 = (_shares * address(this).balance) / totalSupply;
        amount1 = (_shares * token.balanceOf(address(this))) / totalSupply;
        require(amount0 > 0 && amount1 > 0, "amount0 or amount1 = 0");

        _burn(msg.sender, _shares);
        _update(address(this).balance - amount0, token.balanceOf(address(this)) - amount1);

        payable(msg.sender).transfer(amount0);
        token.transfer(msg.sender, amount1);
    }

    function _sqrt(uint256 x) public pure returns (uint256) {
    if (x == 0) return 0;
    
    uint256 z = (x + 1) / 2;
    uint256 y = x;
    
    while (z < y) {
        y = z;
        z = (x / z + z) / 2;
    }
    
    return y;
    }
    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }
    function getETHPrice() public view returns (uint256) {
    require(reserve0 + reserve1 > 0, "Invalid reserves");
    return (reserve1 * 1 ether) / reserve0;
    }
    function getERCPrice() public view returns (uint256) {
    require(reserve0 + reserve1 > 0, "Invalid reserves");
    return (reserve0 * 1 ether) / reserve1;
    }


}
// interface IERC20 {
//     function totalSupply() external view returns (uint256);

//     function balanceOf(address account) external view returns (uint256);

//     function transfer(address recipient, uint256 amount) external returns (bool);

//     function allowance(address owner, address spender) external view returns (uint256);

//     function approve(address spender, uint256 amount) external returns (bool);

//     function transferFrom(
//         address sender,
//         address recipient,
//         uint256 amount
//     ) external returns (bool);

//     event Transfer(address indexed from, address indexed to, uint256 amount);
//     event Approval(address indexed owner, address indexed spender, uint256 amount);
// }
