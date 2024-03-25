// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Week22Exercise2} from "../src/Week22Exercise2.sol";

contract Week22Exercise2Test is Test {
    Week22Exercise2 public exercise2;

    function setUp() public {
        exercise2 = new Week22Exercise2();
    }

    function test_challenge() public {
        // signature can be find in  https://optimistic.etherscan.io/address/0x0000000ccc7439f4972897ccd70994123e0921bc
        string memory message = "attack at dawn";
        bytes
            memory signature = hex"e5d0b13209c030a26b72ddb84866ae7b32f806d64f28136cb5516ab6ca15d3c438d9e7c79efa063198fda1a5b48e878a954d79372ed71922003f847029bf2e751b";

        exercise2.challenge(message, signature);

        require(exercise2.getUsed(signature), "not hack");
    }
}
