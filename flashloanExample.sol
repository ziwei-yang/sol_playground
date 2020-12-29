// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.6.6;

import "https://github.com/aave/flashloan-box/blob/Remix/contracts/aave/FlashLoanReceiverBase.sol";
import "https://github.com/aave/flashloan-box/blob/Remix/contracts/aave/ILendingPoolAddressesProvider.sol";
import "https://github.com/aave/flashloan-box/blob/Remix/contracts/aave/ILendingPool.sol";


contract Flashloan is FlashLoanReceiverBase {
    constructor(address _addressProvider) FlashLoanReceiverBase(_addressProvider) Ownable() public {}
    
    string status = "INIT";
    
    function flashloan(address _asset) public onlyOwner {
        bytes memory data = "";
        uint amount = 1000000000000000000;
        
        status = "flashloan start";

        ILendingPool lendingPool = ILendingPool(addressesProvider.getLendingPool());
        lendingPool.flashLoan(address(this), _asset, amount, data);
    }
    
    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata
    )
        external
        override
    {
        require(_amount <= getBalanceInternal(address(this), _reserve), "Invalid balance, was the flashLoan successful?");

        status = "Your logic goes here.";

        uint totalDebt = _amount.add(_fee);
        transferFundsBackToPoolInternal(_reserve, totalDebt);
    }
}
