// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.6;

contract RemoteCallExample {
    event ETHReceived(address, uint);
    event WETHBalance(uint);
    event RemoteCall(address, uint, string, uint, bytes); // target, value, func, payload.length, payload
    
    address payable weth_address = 0xc778417E063141139Fce010982780140Aa0cD5Ab; // Ropsten WETH9
    
    /**
     * It is executed on a call to the contract with empty calldata.
     * This is the function that is executed on plain Ether transfers (e.g. via .send() or .transfer()).
     * If no such function exists, but a payable fallback function exists,
     * the fallback function will be called on a plain Ether transfer.
     * If neither a receive Ether nor a payable fallback function is present,
     * the contract cannot receive Ether through regular transactions and throws an exception.
     **/
    receive() external payable { emit ETHReceived(msg.sender, msg.value); }
    fallback() external payable { emit ETHReceived(msg.sender, msg.value); }
    
    function queryWETHBalance() public returns(uint) {
        bytes memory ret_bytes = remoteCall(
            weth_address,
            "balanceOf(address)",
            abi.encodeWithSignature("balanceOf(address)", address(this))
        );
        uint weth_bal = sliceUint(ret_bytes, 0);
        emit WETHBalance(weth_bal);
        return weth_bal;
    }
    
    function wrapETH() public payable {
        require(msg.value > 0, "No ETH received");
        
        queryWETHBalance();
        
        // Deposit ETH, get WETH
        remoteCallWithETH(
            weth_address,
            "deposit()",
            abi.encodeWithSignature("deposit()"),
            msg.value
        );
        
        queryWETHBalance();
    }
    
    function withdrawAll() public {
        uint weth_bal = queryWETHBalance();
        
        // Call WETH9.withdraw(uint) through ABI
        remoteCall(
            weth_address,
            "withdraw(uint256)",
            abi.encodeWithSignature("withdraw(uint256)", weth_bal)
        );
        
        // Send contract all ETH back to user.
        msg.sender.transfer(address(this).balance);
    }
    
    //////////////////////// ABI Functions //////////////////////////////
    
    function encodeFuncSelector(string memory _func_name) public pure returns(bytes memory) {
        bytes memory selector = abi.encodeWithSignature(_func_name);
        return selector;
    }
    
    /**
     * _payload = abi.encodeWithSignature("funcName(types...)", args...)
     */
    function remoteCall(address addr, string memory memo, bytes memory _payload) public returns(bytes memory) {
        bytes memory payload = _payload;
        emit RemoteCall(addr, 0, memo, payload.length, payload);
        (bool ret, bytes memory result) = addr.call(payload);
        require(ret, memo);
        return result;
    }
    function remoteCallWithETH(address addr, string memory memo, bytes memory _payload, uint _eth) public returns(bytes memory) {
        bytes memory payload = _payload;
        emit RemoteCall(addr, _eth, memo, payload.length, payload);
        (bool ret, bytes memory result) = addr.call{value: _eth}(payload);
        require(ret, memo);
        return result;
    }
    
    function sliceUint(bytes memory bs, uint start) public pure returns (uint) {
        require(bs.length >= start + 32, "sliceUint out of range");
        uint x;
        assembly {
            x := mload(add(bs, add(0x20, start)))
        }
        return x;
    }
}
