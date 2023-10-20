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
        SimpleERC223Token token =  tokenBankChallenge.token();
        console.log("tokenBankChallenge balance for SimpleERC223Token",token.balanceOf(address(tokenBankChallenge))); // goal: 1000000000000000000000000 => 0
        console.log("player balance for player",token.balanceOf(player));

        //  mapping(address => uint256) storage test = tokenBankChallenge.balanceOf(pla);

        console.log("player balance for tokenBankChallenge",tokenBankChallenge.balanceOf(player));

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenBankChallenge.isComplete(), "Challenge Incomplete");
    }
}
