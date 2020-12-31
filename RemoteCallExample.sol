// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.6;

import "https://github.com/ziwei-yang/sol_playground/blob/main/lib/WETH9.sol";

contract RemoteCallExample {
    
    address payable weth_contract = 0xc778417E063141139Fce010982780140Aa0cD5Ab; // Ropsten WEH9
    
    // Works
    function wrapETH() public payable {
        require(msg.value > 0, "No ETH received");
        // Deposit ETH, get WETH
        WETH9(weth_contract).deposit{value: msg.value}();
    }
    
    function testWETH() public payable {
        require(msg.value > 0, "No ETH received");
        // Deposit ETH, get WETH
        WETH9(weth_contract).deposit{value: msg.value}();
        WETH9 weth = WETH9(weth_contract);
        uint bal = weth.balanceOf(address(this));
        
        // Call WETH9.withdraw(uint) through ABI
        invoke(weth_contract, "withdraw(uint)", bal); // Does not work.
        // weth.withdraw(bal);
        
        // Send contract all ETH back to user.
        msg.sender.transfer(address(this).balance);
    }
    
    /**
     * func_desc "funcName(type)"
     */
    function invoke(address addr, string memory _func_desc, uint _val) public returns(bool success) {
        (bool ret,  ) = addr.call(abi.encodeWithSignature(_func_desc, _val));
        require(ret, _func_desc);
        return true;
    }
}
