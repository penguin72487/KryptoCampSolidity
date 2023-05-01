// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db","0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB","0x617F2E2fD72FD9D5503197092aC168c91465E7f2","0x17F6AD8Ef982297579C203069C1DbfFE4348c372"]
//["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db","0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB","0x617F2E2fD72FD9D5503197092aC168c91465E7f2","0x17F6AD8Ef982297579C203069C1DbfFE4348c372"]
//[2000,2000,1000,1000,1000]



/*代幣合約(繼承ERC20)*/
contract teamToken is ERC20 {
    uint8 private _decimals;
    uint256 private _totalSupply;
    address public _owner;
    //address public _token;
    //IERC20 ourToken = IERC20(_token); // 宣告IERC合約變量
    



    //建構子
    constructor(string memory name, string memory symbol,uint8 decimals_,uint256 totalSupply_) ERC20(name,symbol){
        _decimals = decimals_;
        _totalSupply = totalSupply_;
        _owner = msg.sender;

    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function mint(address to, uint256 amount) external{
        _mint(to,amount);
    }

}

