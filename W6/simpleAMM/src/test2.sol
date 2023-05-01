// SPDX-License-Identifier: GPL-3.0

pragma solidity^ 0.8.18;

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



/*空頭合約
@notice 向多個地址轉帳ERC20代幣 使用前須先授權
@param _token 轉帳的ERC20代幣合約地址
@param _addresses 接收空投用戶的地址數組
@param _amounts 對應每個接收空投用戶要接收的代幣數量數組
*/
contract Airdrop {
    function multiTransferToken(address _token,address[] calldata _addresses,uint256[] calldata _amounts) external payable {
    // 檢查：_addresses和_amounts數組的長度是否相等(1對1關係)
    require(_addresses.length == _amounts.length, "Lengths of Addresses and Amounts NOT EQUAL");
    IERC20 token = IERC20(_token); // 宣告IERC合約變量
    uint _amountSum = getSum(_amounts); // 統計空投代幣總數量
    // 檢查：授權代幣數量 >= 空投代幣總數量
    require(token.allowance(msg.sender, address(this)) >= _amountSum, "Need Approve ERC20 token");
    
    // for循環 利用transferFrom函數發送空投
    for (uint8 i; i < _addresses.length; i++) {
        token.transferFrom(msg.sender, _addresses[i], _amounts[i]);
    }
}

    function getSum(uint256[] calldata _arr) public pure returns(uint sum)
    {
        for(uint i = 0; i < _arr.length; i++)
            sum = sum + _arr[i];
    }

}

contract Trade {
    uint256 public _tokensPerEther;
    event BuyTokens(address buyer, uint256 amountOfEther, uint256 amountOfTokens);


    constructor(uint256 tokensPerEther_) {
        _tokensPerEther = tokensPerEther_;
    }

    function buyTokens(address _token) payable public {
        IERC20 token = IERC20(_token); // 宣告IERC合約變量
        uint256 amountTobuy = msg.value* _tokensPerEther;
        uint256 tradeBalance = token.balanceOf(address(this));
        require(amountTobuy > 0, "You need to send some ether");
        require(tradeBalance >= amountTobuy, "Vendor has insufficient tokens");
        (bool sent) = token.transfer(msg.sender, amountTobuy);
        require(sent, "Failed to transfer token to user");
        emit BuyTokens(msg.sender, msg.value, amountTobuy);
    }

    function sellTokens(address _token,uint256 tokenAmountToSell) public {
        IERC20 token = IERC20(_token); // 宣告IERC合約變量
        require(tokenAmountToSell > 0, "Specify an amount of token greater than zero");
        uint256 userBalance = token.balanceOf(msg.sender);
        require(userBalance >= tokenAmountToSell, "You have insufficient tokens");
        uint256 amountOfEtherToTransfer = tokenAmountToSell / _tokensPerEther;
        uint256 ownerEtherBalance = address(this).balance;
        require(ownerEtherBalance >= amountOfEtherToTransfer, "Vendor has insufficient funds");
        (bool sent) = token.transferFrom(msg.sender, address(this), tokenAmountToSell);
        require(sent, "Failed to transfer tokens from user to vendor");
        (sent,) = msg.sender.call{value: amountOfEtherToTransfer}("");
        require(sent, "Failed to send Ether to the user");
    }


}



