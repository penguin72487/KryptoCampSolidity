// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

// testGoaDuck tGD
contract testGaoDuckToken is ERC20 {
    constructor (string memory name, string memory symbol) ERC20(name, symbol) {
        
    }
    
    function mint(address account, uint256 amount) external {
        _mint(account,  amount );
    }

    function burn(address account, uint256 amount) external {
        _burn(account, amount);
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
}
//0xcD6a42782d230D7c13A74ddec5dD140e55499Df9
