pragma solidity 0.7.5;

import "../src/token2.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.7.5
///      echidna EchidnaTest/solution2.sol
///      ```
contract TestToken is Token {
    constructor() public {
        pause(); // pause the contract
        owner = address(0); // lose ownership
    }
    
    function echidna_cannot_be_unpause() public view returns (bool) {
        return paused() == true;
    }
    

    // echidna EchidnaTest/solution2.sol --test-mode assertion
    function testPaused(uint amount) public {
        assert(paused());
    }
    
}