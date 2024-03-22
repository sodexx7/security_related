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
        string
            calldata message = "0xa040461c36f1f47072e94f7d19461be1dbd322a1c2c2b5793af42b0d72bbab3f";
        bytes
            calldata signature = "0xa6047212f38d40142e7271bfb75cf8c601f64be37f08a9a3ca6c797d48d773db6af5744aa60dc962202eb641c1c94126589355706812e9602c435cc09d160dc91b";

        exercise2.challenge(message, signature);

        assertTrue(exercise2.used[signature]);
    }
}
