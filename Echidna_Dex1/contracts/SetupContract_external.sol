// SPDX-License-Identifier: MIT
// reference source: https://github.com/OpenZeppelin/ethernaut/blob/master/contracts/contracts/levels/DexFactory.sol
pragma solidity ^0.8.0;

import './Dex.sol';
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
  This set up apply echidna external method test the Dex.

  The below are considerations:
  1: directly create the dex and get the dex instance.
  2: set the play as the SetupContract itself, which means the contract will have 10 token1 and 10 token2 after deployed.
  3: Because the SetupContract is the intermediate contract, the SetupContract will become the defalut owner of the dex while setting, which obviously that player shouldn't have the ownership, so transferOwnership to other address.

  4.Keep in mind while do the echidna test, msg.sender means the the default echidna's randomly eoa contracts, and address(this) means player, these points can compare to the echidna internal method
  So when setup the contract should notice the difference.

  5. in order to just use the player(SetupContract) to test, so it doesn't matter who address call the player. So Can limit the player is one address.
   My method is add require(msg.sender == address(0x30000)); in the beginning of the funciton:swap_test. another ways is modify sender's value in the config file, but it seems not work.

  echidna contracts/SetupContract_external.sol --contract SetupContract --config echidna.yaml
 */

contract SetupContract  {

  address echidna_player = address(this); // player 
  Dex instance;// Dex contract

  event CheckAddress(address);
  constructor() {
    instance = new Dex();
    address instanceAddress = address(instance);
    
    SwappableToken tokenInstance = new SwappableToken(instanceAddress, "Token 1", "TKN1", 110);
    SwappableToken tokenInstanceTwo = new SwappableToken(instanceAddress, "Token 2", "TKN2", 110);
    
    address tokenInstanceAddress = address(tokenInstance);
    address tokenInstanceTwoAddress = address(tokenInstanceTwo);

    instance.setTokens(tokenInstanceAddress, tokenInstanceTwoAddress);
    
    tokenInstance.approve(instanceAddress, 100);
    tokenInstanceTwo.approve(instanceAddress, 100);

    instance.addLiquidity(tokenInstanceAddress, 100);
    instance.addLiquidity(tokenInstanceTwoAddress, 100);


    tokenInstance.transfer(echidna_player, 10);
    tokenInstanceTwo.transfer(echidna_player, 10);

    instance.transferOwnership(address(0x40000));
  }
  
    event BalanceOfPlayer(uint);
    event BalanceOfDex(uint);
    

    function swap_test(address from,address to) public {
        require(msg.sender == address(0x10000));
        
        require( (from == instance.token1() && to == instance.token2()) || (from == instance.token2() && to == instance.token1()));
        uint amount = IERC20(from).balanceOf(address(this));
        // require(amount <=amountBalance);

        uint beforeAmountForFrom = instance.balanceOf(from,address(instance));
        uint beforedAmountForTo = instance.balanceOf(to,address(instance));

        uint swapAmount = instance.getSwapPrice(from, to, amount);
        require(swapAmount>0);

        instance.approve(address(instance),amount);
        instance.swap(from,to,amount);
       

        uint afterAmountForFrom = instance.balanceOf(from,address(instance));
        uint afterdAmountForTo = instance.balanceOf(to,address(instance));

        if(afterAmountForFrom+ afterdAmountForTo < beforeAmountForFrom + beforedAmountForTo){

          uint playerBalanceOfFrom = instance.balanceOf(from,echidna_player);
          uint playerBalanceOfTo = instance.balanceOf(to,echidna_player);
          emit BalanceOfPlayer(playerBalanceOfFrom + playerBalanceOfTo);
          emit BalanceOfDex(afterAmountForFrom+afterdAmountForTo);
          emit CheckAddress(msg.sender);
        }
        assert(afterAmountForFrom+ afterdAmountForTo == beforeAmountForFrom + beforedAmountForTo);
      
    }



    // event beforeCallAMount(uint);
    // event afterCallAMount(uint);
    // function test_swap2(address from,address to) public{

    //   test_swap1TO2(from,to);
    //   test_swap2TO1(to,from);
    //   test_swap1TO2(from,to);
    //   test_swap2TO1(to,from);

    //    uint afterAmountForFrom = instance.balanceOf(from,address(instance));
    //   uint afterdAmountForTo = instance.balanceOf(to,address(instance));


    //   uint playerBalanceOfFrom = instance.balanceOf(from,echidna_player);
    //   uint playerBalanceOfTo = instance.balanceOf(to,echidna_player);
    //   emit BalanceOfPlayer(playerBalanceOfFrom + playerBalanceOfTo);
    //   emit BalanceOfDex(afterAmountForFrom+afterdAmountForTo);

    //   assert(false);
    //   // uint afterAmountForFrom = instance.balanceOf(from,address(instance));
    //   // uint afterdAmountForTo = instance.balanceOf(to,address(instance));


    //   // if(afterAmountForFrom+ afterdAmountForTo < amountPlayerFromDex + amountPlayerToDex){

    //   //   uint playerBalanceOfFrom = instance.balanceOf(from,echidna_player);
    //   //   uint playerBalanceOfTo = instance.balanceOf(to,echidna_player);
    //   //   emit BalanceOfPlayer(playerBalanceOfFrom + playerBalanceOfTo);
    //   //   emit BalanceOfDex(afterAmountForFrom+afterdAmountForTo);
    //   // }
    //   // assert(afterAmountForFrom+ afterdAmountForTo == amountPlayerFromDex + amountPlayerToDex);

      

    //   // while(true){

    //   //   if(amountPlayerFrom <= amountPlayerFromDex){
    //   //     uint amount = IERC20(from).balanceOf(address(this));
    //   //     test_swap1TO2(from,to,amount);
    //   //   } else {
    //   //     test_swap1TO2(from,to,amountPlayerFromDex);
    //   //   }

    //   //   if(amountPlayerFromDex == 0 || amountPlayerToDex == 0){
    //   //     assert(false);
        
    //   //   }


    //   //    amountPlayerFrom = IERC20(from).balanceOf(address(this));
    //   //    amountPlayerFromDex = IERC20(from).balanceOf(address(instance));
    //   //    amountPlayerTo = IERC20(to).balanceOf(address(this));
    //   //    amountPlayerToDex = IERC20(to).balanceOf(address(instance));

    //   //   if(amountPlayerTo <= amountPlayerToDex){
    //   //   uint amount = IERC20(from).balanceOf(address(this));
    //   //     test_swap2TO1(to,from,amountPlayerTo);
    //   //   } else {
    //   //     test_swap2TO1(to,from,amountPlayerToDex);
    //   //   }

    //   //   if(amountPlayerFromDex == 0 || amountPlayerToDex == 0){
    //   //     assert(false);
    //   //   }
    //   // }
      
    // }


    // function test_swap1TO2(address from,address to) internal{

    //     require(  to == instance.token1() && from == instance.token2());

    //     // require(IERC20(from).balanceOf(address(this)) >= amount && amount > 0 );

    //     uint beforeAmountForFrom = instance.balanceOf(from,address(instance));
    //     uint beforedAmountForTo = instance.balanceOf(to,address(instance));

    //     uint amount = instance.balanceOf(from,msg.sender);
    //     uint swapAmount = instance.getSwapPrice(from, to, amount);
    //     require(swapAmount>0);
        
    //     instance.approve(address(instance),amount);
    //     instance.swap(from,to,amount);


    //     // uint afterAmountForFrom = instance.balanceOf(from,address(instance));
    //     // uint afterdAmountForTo = instance.balanceOf(to,address(instance));


    //     // if(afterAmountForFrom+ afterdAmountForTo < beforeAmountForFrom + beforedAmountForTo){

    //     //   uint playerBalanceOfFrom = instance.balanceOf(from,echidna_player);
    //     //   uint playerBalanceOfTo = instance.balanceOf(to,echidna_player);
    //     //   emit BalanceOfPlayer(playerBalanceOfFrom + playerBalanceOfTo);
    //     //   emit BalanceOfDex(afterAmountForFrom+afterdAmountForTo);
    //     // }
    //     // assert(afterAmountForFrom+ afterdAmountForTo == beforeAmountForFrom + beforedAmountForTo);

    // }

    // function test_swap2TO1(address from,address to) internal{
    //     require(  to == instance.token2() && from == instance.token1());

    //     // require(IERC20(from).balanceOf(address(this)) >= amount && amount > 0 );

    //     uint beforeAmountForFrom = instance.balanceOf(from,address(instance));
    //     uint beforedAmountForTo = instance.balanceOf(to,address(instance));
    //     uint amount = instance.balanceOf(from,msg.sender);
    //     uint swapAmount = instance.getSwapPrice(from, to, amount);
    //     require(swapAmount>0);
        
    //     instance.approve(address(instance),amount);
    //     instance.swap(from,to,amount);


    //     // uint afterAmountForFrom = instance.balanceOf(from,address(instance));
    //     // uint afterdAmountForTo = instance.balanceOf(to,address(instance));


    //     // if(afterAmountForFrom+ afterdAmountForTo < beforeAmountForFrom + beforedAmountForTo){

    //     //   uint playerBalanceOfFrom = instance.balanceOf(from,echidna_player);
    //     //   uint playerBalanceOfTo = instance.balanceOf(to,echidna_player);
    //     //   emit BalanceOfPlayer(playerBalanceOfFrom + playerBalanceOfTo);
    //     //   emit BalanceOfDex(afterAmountForFrom+afterdAmountForTo);
    //     // }
    //     // assert(afterAmountForFrom+ afterdAmountForTo == beforeAmountForFrom + beforedAmountForTo);

    // }

      
}