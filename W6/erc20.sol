// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// testGoaDuck tGD
contract testGaoDuckToken is ERC20{
    constructor (string memory name, string memory symbol) ERC20(name,symbol){
        
    }
    function mint(address account, uint256 amount) external {
        _mint(account,  amount * (10 ** decimals()));
    }

    function burn(address account, uint256 amount) external{
        _burn(account, amount * (10 ** decimals()));
    }
    
}

//goerli 0xae6B0f75b55fa4c90b2768e3157b7000241A41c5
// VM merge 0xa9d281dA3B02DF2ffc8A1955c45d801B5726661D

