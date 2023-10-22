// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.7.5;

import "../src/token4.sol";


/// @dev Run the template with
///      ```
///      solc-select use 0.7.5
///      echidna EchidnaTest/solution4.sol --contract TestToken --test-mode assertion
///      
///      ```
contract TestToken is Token {

    event AssertionFailed(uint256,uint256);

    function transfer(address to, uint256 value) public override {

        uint256 oldBalanceFrom = balances[msg.sender];
        uint256 oldBalanceTo = balances[to];

        super.transfer(to, value);

        if(balances[msg.sender] > oldBalanceFrom){
            emit AssertionFailed(balances[msg.sender],oldBalanceFrom);
        }
        // assert(balances[msg.sender] <= oldBalanceFrom);
        if(balances[to] < oldBalanceTo){
            emit AssertionFailed(balances[to],oldBalanceTo);
        }
        // assert(balances[to] >= oldBalanceTo);
    }
}