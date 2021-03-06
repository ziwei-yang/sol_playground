// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.6;

// import "https://github.com/ziwei-yang/sol_playground/blob/main/lib/uniswap/contracts/UniswapV2Router02.sol";
import "https://github.com/ziwei-yang/sol_playground/blob/main/lib/openzeppelin/contracts/token/ERC20/ERC20.sol";
import "https://github.com/ziwei-yang/sol_playground/blob/main/ABIHelper.sol";

contract MintableToken is ERC20 {
    constructor (string memory name_, string memory symbol_) ERC20 (name_, symbol_) public {
    }
    
    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}

contract UniswapExample  {
    // UniswapV2Router02 public router;
    address payable uniswap_router_addr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address payable public weth_addr; // Ropsten 0xc778417E063141139Fce010982780140Aa0cD5Ab
    address payable public uniswap_factory_addr;
    address payable public uniswap_pair_addr;
    string public debug_str;
    uint public debug_uint;
    bytes public debug_bytes;
    
    event RemoteCall(address, uint, string, uint, bytes);
    
    MintableToken public tokenA;
    MintableToken public tokenB;
    
    constructor() public {
        (bool ret, bytes memory result) = uniswap_router_addr.call(abi.encodeWithSignature("WETH()"));
        require(ret, "get WETH() failed");
        debug_bytes = result;
        weth_addr = payable(ABIHelper.bytesToAddress(result));
        
        (ret, result) = uniswap_router_addr.call(abi.encodeWithSignature("factory()"));
        require(ret, "get factory() failed");
        debug_bytes = result;
        uniswap_factory_addr = payable(ABIHelper.bytesToAddress(result));
        
        tokenA = new MintableToken("TokenA", "TKA");
        tokenB = new MintableToken("TokenB", "TKB");
        debug_str = 'init';
        
        // Prepare Tokens and Uniswap Pair
        tokenA.mint(address(this), 506605653443769015038);
        tokenB.mint(address(this), 506605653443769015038);
        // uniswap_pair_addr = payable(
        //     IUniswapV2Factory(uniswap_factory_addr).createPair(address(tokenA), address(tokenB))
        // );
        
        // Approve Router to transfer tokens
        tokenA.approve(uniswap_router_addr, uint(-1));
        tokenB.approve(uniswap_router_addr, uint(-1));
        // TransferHelper.safeApprove(address(tokenA), uniswap_router_addr, uint(-1));
        // TransferHelper.safeApprove(address(tokenB), uniswap_router_addr, uint(-1));
    }
    
    //////////////// TOKENS ///////////////////////////
    function mintTokenA(address account, uint256 amount) public {
        tokenA.mint(account, amount);
    }
    function mintTokenA(uint256 amount) public {
        tokenA.mint(address(this), amount);
    }
    function tokenABalanceOf(address _address) public view returns (uint){
        return tokenA.balanceOf(_address);
    }
    function tokenABalance() public view returns (uint){
        return tokenA.balanceOf(address(this));
    }
    function tokenASwapAllowance() public view returns (uint){
        return tokenA.allowance(address(this), address(uniswap_router_addr));
    }
    
    function mintTokenB(address account, uint256 amount) public {
        tokenB.mint(account, amount);
    }
    function mintTokenB(uint256 amount) public {
        tokenB.mint(address(this), amount);
    }
    function tokenBBalanceOf(address _address) public view returns (uint){
        return tokenB.balanceOf(_address);
    }
    function tokenBBalance() public view returns (uint){
        return tokenB.balanceOf(address(this));
    }
    function tokenBSwapAllowance() public view returns (uint){
        return tokenB.allowance(address(this), address(uniswap_router_addr));
    }
    
    //////////////// UNISWAP ROUTER ///////////////////////////
    function addLiquidity(uint _tokenAQty, uint _tokenBQty) public {
        // https://uniswap.org/docs/v2/smart-contracts/router02/#addliquidity
        // (uint amountA, uint amountB, uint liquidity) = UniswapV2Router02(uniswap_router_addr).addLiquidity(
        //     address(tokenA), address(tokenB),
        //     _tokenAQty, _tokenBQty, _tokenAQtyMin, _tokenBQtyMin,
        //     address(this), (block.timestamp + 1 days)
        // );
        string memory func_desc = "addLiquidity(address,address,uint256,uint256,uint256,uint256,address,uint256)";
        ABIHelper.remoteCall(
            uniswap_router_addr,
            func_desc,
            abi.encodeWithSignature(
                func_desc,
                address(tokenA), address(tokenB),
                _tokenAQty, _tokenBQty, uint(1), uint(1),
                address(this), (block.timestamp + 1 days)
            ),
            0
        );
    }
    function queryPair() public returns (bytes memory){
        return ABIHelper.remoteCall(
            uniswap_factory_addr,
            "getPair(address,address)",
            abi.encodeWithSignature("getPair(address,address)", address(tokenA), address(tokenB)),
            0
        );
    }
    function createPair() public returns (bytes memory){
        // create the pair if it doesn't exist yet
        // if (IUniswapV2Factory(uniswap_factory_addr).getPair(address(tokenA), address(tokenB)) == address(0)) {
        //     IUniswapV2Factory(uniswap_factory_addr).createPair(address(tokenA), address(tokenB));
        // }
        return ABIHelper.remoteCall(
            uniswap_factory_addr,
            "createPair(address,address)",
            abi.encodeWithSignature("createPair(address,address)", address(tokenA), address(tokenB)),
            0
        );
    }
    // function getReserves() public view returns (uint, uint) {
    //     (uint reserveA, uint reserveB) = UniswapV2Library.getReserves(uniswap_factory_addr, address(tokenA), address(tokenB));
    //     return (reserveA, reserveB);
    // }
    
    function swapTokenAforTokenB(uint _tokenAQty) public {
        // https://uniswap.org/docs/v2/smart-contracts/router02/#swapexacttokensfortokens
        address[] memory path = new address [](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);
        // uint[] memory amounts = UniswapV2Router02(uniswap_router_addr).swapExactTokensForTokens(
        //     _tokenAQty, _tokenAQty,
        //     path,
        //     address(this), (block.timestamp + 1 days)
        // );
        // debug_uint = amounts[amounts.length-1];
        bytes memory result = ABIHelper.remoteCall(
            uniswap_router_addr,
            "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)",
            abi.encodeWithSignature(
                "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)",
                _tokenAQty, _tokenAQty,
                path,
                address(this), (block.timestamp + 1 days)
            ),
            0
        );
        debug_bytes = result;
        // uint[] memory amounts = abi.decode(result, (uint[]));
        // debug_uint = amounts[amounts.length-1];
        debug_uint = ABIHelper.sliceUint(result, result.length-32);
    }
}
