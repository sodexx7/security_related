// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract GuessTheSecretNumber {
    bytes32 answerHash =
        0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable returns (bool) {
        require(msg.value == 1 ether);

        if (keccak256(abi.encodePacked(n)) == answerHash) {
            (bool ok, ) = msg.sender.call{value: 2 ether}("");
            require(ok, "Failed to Send 2 ether");
        }
        return true;
    }
}

// Write your exploit codes below
contract ExploitContract {
    bytes32 answerHash =
        0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;

    /**
    1.First get the slot 0's value at the GuessTheSecretNumber's address, which can get by the testStorage funciton in GuessSecretNumberTest, There Have been applied.
    2.Because the the password's type is uint8, so the max value is 255. just use the brute way to break down the password like below code.
     */
    function Exploiter() public view returns (uint8) {
        uint8 n;

        while(keccak256(abi.encodePacked(n)) != answerHash){
            ++n;
        }

        return n;
    }
}
