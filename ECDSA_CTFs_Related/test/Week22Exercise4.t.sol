// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {Week22Exercise4} from "../src/Week22Exercise4.sol";

contract Week22Exercise4Test is Test {
    Week22Exercise4 public exercise4;
    function setUp() public {
        exercise4 = new Week22Exercise4();
    }

    function test_challenge4() public {
        bytes32 r = hex"19c721d5409174ee9e8668834eb1416f3dbf07ba07bd7bf4accac4a1acc757c0";
        bytes32 s = hex"42cafe60bd1149a843a08ed5cf3311d40c4c4c928f28d27897289df580a2e2ec";
        uint8 v = 27;

        // v: 1b, 1c try

        bytes memory signature = abi.encodePacked(r, s, v);
        console2.logBytes(signature);

        bytes32 hash = hex"30ace18afcdbfe4c0e3914491a4dbce9c99e31a4ecd2d79d77e13648b980dde7";
        exercise4.claimAirdrop(uint256(1), hash, signature);

        console2.log(exercise4.getHacked());
    }
}
