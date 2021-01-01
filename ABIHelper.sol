  // SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library ABIHelper {
    //////////////////////// ABI Functions //////////////////////////////
    // _func_desc = 'approve(address,uint256)'
    function encodeFuncSelector(string memory _func_desc) public pure returns(bytes4) {
        return bytes4(keccak256(bytes(_func_desc)));
    }
    /**
     * _payload = abi.encodeWithSignature("funcName(types...)", args...)
     * _payload = abi.encodeWithSelector(0xa9059cbb, args...)
     */
    function remoteCall(address addr, string memory memo, bytes memory _payload, uint _eth) public returns(bytes memory) {
        bytes memory payload = _payload;
        // emit RemoteCall(addr, _eth, memo, payload.length, payload);
        (bool ret, bytes memory result) = addr.call{value: _eth}(payload);
        require(ret, memo);
        // debug_bytes = result;
        return result;
    }
    function bytesToAddress(bytes memory bys) public pure returns (address addr) {
        uint size = bys.length; // Slice last 20 bits from bys tail
        assembly {
          addr := mload(add(bys,size))
        } 
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
