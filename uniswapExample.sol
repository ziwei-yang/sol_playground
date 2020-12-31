// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.6;

import "https://github.com/ziwei-yang/sol_playground/blob/main/lib/uniswap/contracts/UniswapV2Router02.sol";
import "https://github.com/ziwei-yang/sol_playground/blob/main/lib/openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MintableToken is ERC20 {
    constructor (string memory name_, string memory symbol_) ERC20 (name_, symbol_) public {
    }
    
    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}

contract Example  {
    UniswapV2Router02 public router;
    address payable public weth_addr;
    string public debug_str;
    uint public debug_uint;
    
    MintableToken public tokenA;
    MintableToken public tokenB;
    
    constructor() public {
      router = UniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
      weth_addr = payable(address(router.WETH())); // 0xc778417E063141139Fce010982780140Aa0cD5Ab
      tokenA = new MintableToken("TokenA", "TKA");
      tokenB = new MintableToken("TokenB", "TKB");
      debug_str = 'init';
    }
    
    //////////////// TOKENS ///////////////////////////
    function mintTokenA(address account, uint256 amount) public {
        tokenA.mint(account, amount);
    }
    function mintTokenA(uint256 amount) public {
        tokenA.mint(address(this), amount);
    }
    
    function mintTokenB(address account, uint256 amount) public {
        tokenB.mint(account, amount);
    }
    function mintTokenB(uint256 amount) public {
        tokenB.mint(address(this), amount);
    }
    
    function createPair() public {
        // TODO
    }
    
    function swapTokenAforTokenB() public {
        // TODO
    }
    
    function swapTokenBforTokenA() public {
        // TODO
    }
}
