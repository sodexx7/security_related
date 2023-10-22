// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.7.5;

import "../src/mintable.sol";


/// @dev Run the template with
///      ```
///      solc-select use 0.7.5
///      echidna EchidnaTest/solution3.sol
///      ```

/**
Two problem:
1:the conversion between int256 and uint256
2.oveflow check for: require(value+ totalMinted < totalMintable);
 */
contract TestToken is MintableToken {
    address echidna = msg.sender;

    constructor() public MintableToken(10_000) {
        owner = echidna;

    }

    function echidna_test_balance() public view returns (bool) {
        // TODO: add the property
        //  return totalMinted <= 10_000;
         return balances[echidna] <= 10_000;
         
    }

    

  
}