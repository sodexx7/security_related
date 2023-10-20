// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.7.5;

import "../src/token.sol";

/// @dev Run the solution with
///      ```
///      solc-select use 0.7.5
///      echidna EchidnaTest/solution1.sol
//       echidna EchidnaTest/solution1.sol --test-limit 1000
///      ```
contract TestToken is Token {
    address echidna = msg.sender;

    constructor() {
        balances[echidna] = 10_000;
    }
    
    /**
        properties test
        property-mode
        function echidna_*() public returns (bool)

     */
    function echidna_test_balance() public view returns (bool) {
        return balances[echidna] <= 10000;
    }
}