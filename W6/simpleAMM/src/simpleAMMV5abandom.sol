// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
//goerli 0xae6B0f75b55fa4c90b2768e3157b7000241A41c5
// V1 0xf60440f93a677AB6968E1Fd10cf8a6cE61941131
// V2 0x8b175c421E9307F0365dd37bc32Dda5df95C4946
// V3 0x3ea585565c490232b0379C7D3C3A9fC3fA5C9c0C
// v4 
import "./erc20.sol";
contract AMM {
    IERC20 public immutable token;
    address public constant ETH_ADDRESS = address(0);

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public totalSupply; // total LP
    mapping(address => uint256) public balanceOf;
    mapping (address=>uint256) public au_LPindex;
    mapping (uint256=>address) public ua_LPaddress;
    int256[] public diff_LP;//  differences
    uint256 public sumLP;// sigima diff_LP
 

    constructor(address _token) {
        token = IERC20(_token);
        diff_LP.push(0);
    }

    function _mint(address _to, uint256 _amount) private {
        if(balanceOf[_to]==0)
        {
            au_LPindex[_to]=diff_LP.length;
            ua_LPaddress[diff_LP.length]=_to;
            diff_LP.push(0);
        }
        balanceOf[_to] += _amount;
        totalSupply += _amount;
        
    }

    function _burn(address _from, uint256 _amount) private {
        balanceOf[_from] -= _amount/_shareBaseOf(_from);
        totalSupply -= _amount;
        _removeLiquidityUser(_from);
    }

    function _update(uint256 _reserve0, uint256 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }
    
    

    /* swap */
    function all_addShare() internal { //
        totalSupply+=diff_LP.length-1;
        sumLP+=diff_LP.length-1;
        diff_LP[0]+=1;
        diff_LP[diff_LP.length-1]-=1;
    }
    function swap(uint256 _amountIn) public payable returns (uint256 amountOut) {
        require(msg.value == _amountIn, "ETH amount mismatch");

        uint256 amountInWithFee = (_amountIn * 997) / 1000;
        amountOut = (reserve1 * amountInWithFee) / (reserve0 + amountInWithFee);
        all_addShare();
        token.transfer(msg.sender, amountOut);

        _update(address(this).balance, token.balanceOf(address(this)));
    }
    function swapTokenForETH(uint256 _amountIn) public returns (uint256 amountOut) {
        uint256 amountInWithFee = (_amountIn * 997) / 1000;

        amountOut = (reserve0 * amountInWithFee) / (reserve1 + amountInWithFee);
        require(amountOut > 0, "Insufficient output amount");

        token.transferFrom(msg.sender, address(this), _amountIn);
        payable(msg.sender).transfer(amountOut);

        _update(address(this).balance - amountOut, token.balanceOf(address(this)));
    }
    /* swap */
    /* Liquidity */
    function my_Share() public view returns (uint256) {
        uint256 base = _shareBaseOf(msg.sender);
        return base + balanceOf[msg.sender];
    }
    function all_Share() public view returns (uint256) {
        return totalSupply;
    }
    function share_Of(address _user) public view returns (uint256) {
        uint256 base = _shareBaseOf(_user);
        return base + balanceOf[_user];
    } 
    function _shareBaseOf(address _user) internal view returns (uint256) {
        uint256 base = 0;
        for (uint256 i = 0; i < au_LPindex[_user]; i++) {
            base += uint256(diff_LP[i]);
        }
        return base;
    }
    
    function addLiquidity(uint256 _amount1) external payable returns (uint256 shares) {
        token.transferFrom(msg.sender, address(this), _amount1);

        uint256 _amount0 = msg.value;

        if (reserve0 + reserve1 > 0) {
            if (reserve0 * _amount1 != reserve1 * _amount0) {
                uint256 targetAmount0 = (reserve1 * _amount1) / reserve1;
                uint256 targetAmount1 = (reserve0 * _amount0) / reserve0;

                if (_amount0 < targetAmount0) {
                    uint256 requiredTokenAmount = targetAmount1 - _amount1;
                    uint256 amountOut = swapTokenForETH(requiredTokenAmount);
                    _amount0 += amountOut;
                } else {
                    uint256 requiredEthAmount = targetAmount0 - _amount0;
                    uint256 amountOut = swap(requiredEthAmount);
                    _amount1 += amountOut;
                }
            }
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

    function removeLiquidity(uint256 _share) external
    {
        uint256 share = share_Of(msg.sender);
        require(share>=_share,"shares not enough");
        _removeLiquidity(_share);
    }
    function _removeLiquidityUser(address _user) internal
    {
        require(balanceOf[_user]==0,"balance not empty!");
        uint256 index = au_LPindex[_user];
        uint256 last = diff_LP.length-2;
        uint256 user_shareBase=_shareBaseOf(_user);
        sumLP-=user_shareBase;
        (index,au_LPindex[ua_LPaddress[last]]) = swap(index,au_LPindex[ua_LPaddress[last]]);
        (ua_LPaddress[index],ua_LPaddress[au_LPindex[ua_LPaddress[last]]]) = swap(ua_LPaddress[index],ua_LPaddress[au_LPindex[ua_LPaddress[last]]]);
        swap(diff_LP[diff_LP.length-1],diff_LP[last]);
        diff_LP.pop();
        diff_LP[index+1]-=int256(user_shareBase);
        diff_LP[index]=int256(sumLP-user_shareBase);

    }
    function _removeLiquidity(uint256 _shares) internal returns (uint256 amount0, uint256 amount1) {
        amount0 = (_shares * address(this).balance) / totalSupply;
        amount1 = (_shares * token.balanceOf(address(this))) / totalSupply;
        require(amount0 > 0 && amount1 > 0, "amount0 or amount1 = 0");

        _burn(msg.sender, _shares);
        _update(address(this).balance - amount0, token.balanceOf(address(this)) - amount1);

        payable(msg.sender).transfer(amount0);
        token.transfer(msg.sender, amount1);
    }
    /* Liquidity */
    /* math */
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
    
    function swap(uint256 a,uint256 b) public pure returns (uint256,uint256) {
        uint256 temp = a;
        a = b;
        b = temp;
        return (a,b);
    }
    function swap(int a,int b) public pure returns (int,int) {
        int temp = a;
        a = b;
        b = temp;
        return (a,b);
    }
    function swap(address a,address b) public pure returns (address,address) {
        address temp = a;
        a = b;
        b = temp;
        return (a,b);
    }
    /* math */

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
