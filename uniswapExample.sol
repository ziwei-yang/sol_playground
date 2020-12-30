// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.6;

import "https://github.com/ziwei-yang/sol_playground/blob/main/lib/uniswap/contracts/UniswapV2Router02.sol";
import "https://github.com/ziwei-yang/sol_playground/blob/main/lib/openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Example  {
    UniswapV2Router02 router;
    address payable public router_addr;
    address public weth_addr;
    string public debug;
    
    constructor() public {
      router_addr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
      router = UniswapV2Router02(router_addr);
      debug = 'init';
    }
    
    function serTargetAddr(address payable _t) public {
      router_addr = _t;
      router = UniswapV2Router02(router_addr);
    }
    
    function weth() public returns(address) {
        weth_addr = router.WETH();
        return weth_addr;
    }
    
    /**
     * func_desc "funcName(uint256)"
     */
    function invoke(string memory _func_desc, uint _val) public returns(bool success) {
        (bool ret,  ) = router_addr.call(abi.encodeWithSignature(_func_desc, _val));
        require(ret, "Contract execution Failed");
        return true;
    }
}
