// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.20;

import "../Dex.sol";

/// @dev Run the solution with
///      ```
///      solc-select use 0.8.19
///      echidna EchidnaTest/solution1.sol
//       echidna EchidnaTest/solution1.sol --test-limit 1000
///      ```
contract TestDex is Dex {
    address echidna = msg.sender; // player 
    SwappableToken _token1;
    SwappableToken  _token2;

    constructor() {
        
    }
    
    /**
        properties test
        property-mode
        function echidna_*() public returns (bool)

     */
    // function echidna_test_balance() public view returns (bool) {
    //     return balances[echidna] <= 10000;
    // }
}