// SPDX-License-Identifier: MIT
// reference source: https://github.com/OpenZeppelin/ethernaut/blob/master/contracts/contracts/levels/DexFactory.sol
pragma solidity ^0.8.0;

import './Dex.sol';
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
  This set up apply echidna internal method test the Dex.

  The below are considerations:
  1: Inherited the dex, and the SetupContract itself is the dex.
  2: When deploy the SetupContract contract, the default caller is the  echidna eoa contract(0x30000), so set the player is 0x30000. MeanWihle the player wll be the owner of the 
    SetupContract, so need to transferOwnership to other address.
  3. After set up, the echidna_player(0x30000) will get 10 token1 and 10 token2, and SetupContract itself will get 100 token1 and 100 token2  as pool
  4. One difference comparing external method are  that the player is the eoa in internal method, the player is the smart contract in the external method.

  echidna contracts/SetupContract_internal.sol --contract SetupContract --config echidna.yaml

 */

contract SetupContract is Dex {

  address echidna_player;

  event CheckAddress(address);
  constructor() {
    // emit CheckAddress(msg.sender);
    echidna_player = msg.sender; // player 
    SwappableToken tokenInstance = new SwappableToken(address(this), "Token 1", "TKN1", 110);
    SwappableToken tokenInstanceTwo = new SwappableToken(address(this), "Token 2", "TKN2", 110);
    
    address tokenInstanceAddress = address(tokenInstance);
    address tokenInstanceTwoAddress = address(tokenInstanceTwo);

    setTokens(tokenInstanceAddress, tokenInstanceTwoAddress);
    

    tokenInstance.transfer(echidna_player, 10);
    tokenInstanceTwo.transfer(echidna_player, 10);

    transferOwnership(address(0x40000));
  }

  event BalanceOfPlayer(uint);
  event BalanceOfDex(uint);
  function swap_test(address from,address to) public returns (uint256) {
        
        require(echidna_player == msg.sender);
        emit CheckAddress(msg.sender);

        require( (from == token1 && to == token2) || (from == token2 && to == token1));
        uint amount = balanceOf(from,msg.sender);
        // require(amount<=amountBalace);

        uint swapAmount = getSwapPrice(from, to, amount);
        require(swapAmount>0);

        uint beforeAmountForFrom = balanceOf(from,address(this));
        uint beforedAmountForTo = balanceOf(to,address(this));

        approve(address(this),amount);
        swap(from,to,amount);

        uint afterAmountForFrom = balanceOf(from,address(this));
        uint afterdAmountForTo = balanceOf(to,address(this));

        if(afterAmountForFrom+ afterdAmountForTo < (beforeAmountForFrom + beforedAmountForTo)){

          uint playerBalanceOfFrom = balanceOf(from,echidna_player);
          uint playerBalanceOfTo = balanceOf(to,echidna_player);
          emit BalanceOfPlayer(playerBalanceOfFrom + playerBalanceOfTo);
          emit BalanceOfDex(afterAmountForFrom+afterdAmountForTo);
        }
        assert(afterAmountForFrom+ afterdAmountForTo == beforeAmountForFrom + beforedAmountForTo);
    }

    

}