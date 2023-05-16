// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

// testGoaDuck tGD
contract testGaoDuckToken is ERC20 {
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals_) ERC20(name, symbol) {
        _decimals = decimals_;
    }
    

    function mint(address account, uint256 amount) external {
        _mint(account,  amount );
    }

    function burn(address account, uint256 amount) external {
        _burn(account, amount);
    }
}
interface IExtendedERC20 is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// sepolia
// token0 T0 8 0x5d74d6264b0cbE893EeaDF8c8eEB2783120a465d
// token1 T1 18 0x02B1d2929f6c38f1728b3Fc99dB595FdDfA97bF7