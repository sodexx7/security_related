// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {MintableToken} from "src/mintable.sol";

contract MintableTokenTest is Test {

    address public address1 = address(0x10);
    MintableToken mintableToken;

    function setUp() external {
        // how to let the owner as the address1.
        mintableToken = new MintableToken(10000);
 
    }

    function test_mint() external {
        mintableToken.mint(84123269779407282487160911131333777589715149347871714104310045788395584822028);
        // console.log(mintableToken.balances(address(this)));
      
    }
}

