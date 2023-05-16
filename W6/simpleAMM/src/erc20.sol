// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// testGoaDuck tGD
contract testGaoDuckToken is ERC20 {
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals_) ERC20(name, symbol) {
        _decimals = decimals_;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function mint(address account, uint256 amount) public {
        _mint(account,  amount );
    }

    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }
}
// token0 T0 8 0xafea7BB86Fb50A68db5bD443e0607aab59DF0750
// token1 T1 18 0x4aF233EF89022f4618a3879C7133Ac24d039feee
