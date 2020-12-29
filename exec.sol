// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.7.6;

contract Exec  {
    
    address target_addr;
    
    function serTargetAddr(address _t) public {
        target_addr = _t;
    }
    
    /**
     * func_desc "funcName(uint256)"
     */
    function invoke(string calldata _func_desc, uint _val) public returns(bool success) {
        (bool ret,  ) = target_addr.call(abi.encodeWithSignature(_func_desc, _val));
        require(ret, "Contract execution Failed");
        return true;
    }
}
