pragma solidity 0.7.5;

/// @notice The issues from exercises 1 and 2 are fixed.

import "./token.sol";

contract MintableToken is Token {
    // int256 public totalMinted;
    // int256 public totalMintable;

    

    // constructor(int256 totalMintable_) public {
    //     totalMintable = totalMintable_;
    // }

    // function mint(uint256 value) public onlyOwner {
    //     require(int256(value) + totalMinted < totalMintable);
    //     totalMinted += int256(value);
    //     balances[msg.sender] += value;

    // }


    uint256 public totalMinted;
    uint256 public totalMintable;


    constructor(uint256 totalMintable_) public {
        totalMintable = totalMintable_;
    }

    function mint(uint256 value) public onlyOwner {
        require(value+ totalMinted < totalMintable);
        require(value+ totalMinted > value && value+ totalMinted > totalMinted ); // overflow check
        totalMinted += value;
        balances[msg.sender] += value;

    }

}